using System;
using System.Drawing;
using System.Windows.Forms;

namespace KeeTheme.Decorators
{
    // Replaces only the running main window's icon, never the EXE, shortcut or tray status icon.
    internal sealed class WindowIconDecorator : IDisposable
    {
        private readonly Form _form;
        private readonly Icon _modern;
        private Icon _original;
        private bool _disposed;
        internal WindowIconDecorator(Form form)
        {
            _form = form;
            using (var stream = typeof(WindowIconDecorator).Assembly.GetManifestResourceStream("KeeTheme.Resources.ModernWindow.ico"))
            using (var icon = new Icon(stream))
                _modern = (Icon)icon.Clone();
        }
        internal void Apply(bool enabled)
        {
            if (_disposed || _form.IsDisposed) return;
            if (enabled)
            {
                // KeePass may assign a new colorized icon after switching/locking databases.
                if (!Object.ReferenceEquals(_form.Icon, _modern)) _original = _form.Icon;
                _form.Icon = _modern;
            }
            else if (Object.ReferenceEquals(_form.Icon, _modern)) _form.Icon = _original;
        }
        public void Dispose()
        {
            if (_disposed) return;
            Apply(false);
            _disposed = true;
            _modern.Dispose();
        }
    }
}
