using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace KeeTheme.Decorators
{
    // Keep initial native child paints off screen; restore the original opacity
    // only after the synchronous paint and the theme's after-paint hooks return.
    internal sealed class FirstFrameDecorator : IDisposable
    {
        private readonly Form _form;
        private int _originalStyle;
        private bool _armed;

        [DllImport("user32.dll")]
        private static extern bool RedrawWindow(IntPtr window, IntPtr rectangle, IntPtr region, uint flags);

        [DllImport("user32.dll", ExactSpelling = true)]
        private static extern bool IsWindowVisible(IntPtr window);

        [DllImport("user32.dll", EntryPoint = "GetWindowLongW")]
        private static extern int GetWindowLong(IntPtr window, int index);
        [DllImport("user32.dll", EntryPoint = "SetWindowLongW")]
        private static extern int SetWindowLong(IntPtr window, int index, int value);
        [DllImport("user32.dll")]
        private static extern bool SetLayeredWindowAttributes(IntPtr window, uint key, byte alpha, uint flags);

        internal static bool IsNativeVisible(Form form)
        {
            // WinForms Visible is already true during KeePass Load/WindowAdded.
            // Do not create a handle just to test native presentation state.
            return form.IsHandleCreated && IsWindowVisible(form.Handle);
        }

        internal FirstFrameDecorator(Form form)
        {
            _form = form;
            if (IsNativeVisible(form)) return;
            // Preserve third-party transparency; this guard only owns opaque windows.
            if (form.Opacity != 1 || form.AllowTransparency) return;
            if (!form.IsHandleCreated) { form.HandleCreated += OnHandleCreated; return; }
            Arm();
        }

        private void OnHandleCreated(object sender, EventArgs e)
        {
            _form.HandleCreated -= OnHandleCreated;
            if (!IsNativeVisible(_form)) Arm();
        }

        private void Arm()
        {
            _originalStyle = GetWindowLong(_form.Handle, -20);
            if ((_originalStyle & 0x80000) != 0) return;
            // Form.Opacity calls UpdateStyles while managed Visible is true during
            // Load. That can show the HWND before its final monitor position.
            // Native style/alpha changes must never call ShowWindow or SetWindowPos.
            SetWindowLong(_form.Handle, -20, _originalStyle | 0x80000);
            if (!SetLayeredWindowAttributes(_form.Handle, 0, 0, 2))
            {
                SetWindowLong(_form.Handle, -20, _originalStyle);
                return;
            }
            _armed = true;
            _form.Shown += OnShown;
        }

        private void OnShown(object sender, EventArgs e)
        {
            _form.Shown -= OnShown;
            try
            {
                // INVALIDATE | ERASE | ALLCHILDREN | UPDATENOW.
                // No timers, sleeps, fades or repeated repaint loops.
                if (!_form.IsDisposed) RedrawWindow(_form.Handle, IntPtr.Zero, IntPtr.Zero, 0x0185);
            }
            finally { Restore(); }
        }

        private void Restore()
        {
            if (!_armed) return;
            _armed = false;
            if (!_form.IsDisposed && !_form.Disposing && _form.IsHandleCreated)
            {
                SetLayeredWindowAttributes(_form.Handle, 0, 255, 2);
                // Restore only our bit; preserve changes made by KeePass in Load.
                int style = GetWindowLong(_form.Handle, -20);
                SetWindowLong(_form.Handle, -20, style & ~0x80000);
            }
        }

        public void Dispose()
        {
            _form.Shown -= OnShown;
            _form.HandleCreated -= OnHandleCreated;
            Restore();
        }
    }
}
