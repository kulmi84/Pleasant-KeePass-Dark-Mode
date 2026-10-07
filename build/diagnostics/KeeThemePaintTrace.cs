using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using KeePass.Plugins;
using KeePass.UI;

[assembly: AssemblyTitle("KeeTheme Paint Trace (temporary diagnostics)")]
[assembly: AssemblyProduct("KeePass Plugin")]
[assembly: AssemblyDescription("Temporary metadata-only paint diagnostics for KeeTheme")]
[assembly: AssemblyVersion("1.0.3.0")]
[assembly: AssemblyFileVersion("1.0.3.0")]
namespace KeeThemePaintTrace
{
    public sealed class KeeThemePaintTraceExt : Plugin
    {
        private readonly List<string> records = new List<string>();
        private readonly HashSet<Control> attached = new HashSet<Control>();
        private readonly List<PaintWindow> windows = new List<PaintWindow>();
        private readonly Stopwatch time = Stopwatch.StartNew();
        private readonly object sync = new object();
        private Form main;
        private string path;
        private string saveFailure;

        public override bool Initialize(IPluginHost host)
        {
            if (host == null) return false;
            string workspaceOutput = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "ChatGPT\\KeePass Dark Theme\\outputs");
            path = Path.Combine(Directory.Exists(workspaceOutput) ? workspaceOutput : Path.GetTempPath(), "KeeTheme-ComboTrace.log");
            main = host.MainWindow;
            Record("Diagnostic session. No control text, entry contents, database names, passwords or screenshots recorded.");
            Save(); // Leave startup evidence even if subsequent hook setup fails.
            foreach (Assembly assembly in AppDomain.CurrentDomain.GetAssemblies())
                if (assembly.GetName().Name == "KeeTheme") Record("Theme assembly: " + assembly.GetName().Version);
            try { Attach(main); }
            catch (Exception error) { Record("Attach error type=" + error.GetType().FullName + " HRESULT=" + Marshal.GetHRForException(error).ToString("X8")); }
            GlobalWindowManager.WindowAdded += WindowAdded;
            Save();
            return true;
        }

        private void WindowAdded(object sender, GwmWindowEventArgs e)
        {
            try { Attach(e.Form); }
            catch (Exception error) { Record("Window hook error type=" + error.GetType().FullName); Save(); }
        }
        private void Attach(Control control)
        {
            lock (sync) { if (!attached.Add(control)) return; }
            Form form = control as Form;
            if (form != null)
            {
                Record("Attach " + State(form));
                form.Shown += OnShown;
                form.FormClosed += OnClosed;
            }
            if (control.IsHandleCreated) AttachHandle(control);
            control.HandleCreated += OnHandleCreated;
            foreach (Control child in control.Controls) Attach(child);
        }
        private void AttachHandle(Control control)
        {
            try { lock (sync) { windows.Add(new PaintWindow(control, Record)); } }
            catch (Exception error) { Record("Handle hook error type=" + error.GetType().FullName); }
        }
        private void OnHandleCreated(object sender, EventArgs e) { AttachHandle((Control)sender); }
        private void OnShown(object sender, EventArgs e)
        {
            Form form = (Form)sender;
            Record("Shown " + State(form));
            form.BeginInvoke(new MethodInvoker(delegate { Record("AfterShownQueue " + State(form)); RecordComboStates(form); Save(); }));
        }
        private void RecordComboStates(Control control)
        {
            if (control is ComboBox) Record("ComboAfterShown " + State(control));
            foreach (Control child in control.Controls) RecordComboStates(child);
        }
        private void OnClosed(object sender, FormClosedEventArgs e) { Record("Closed " + ((Form)sender).GetType().Name); Save(); }
        internal static string State(Control control)
        {
            Form form = control.FindForm();
            ComboBox combo = control as ComboBox;
            return control.GetType().Name + " visible=" + control.Visible + " enabled=" + control.Enabled +
                " handle=" + control.IsHandleCreated + " opacity=" + (form == null ? "none" : form.Opacity.ToString(System.Globalization.CultureInfo.InvariantCulture)) +
                " background=" + control.BackColor.ToArgb().ToString("X8") +
                (combo == null ? "" : " drawMode=" + combo.DrawMode + " flatStyle=" + combo.FlatStyle + " dropDownStyle=" + combo.DropDownStyle) +
                (control.IsHandleCreated ? " nativeVisible=" + IsWindowVisible(control.Handle) + " exStyle=" + GetWindowLong(control.Handle, -20).ToString("X8") : "");
        }
        [DllImport("user32.dll")] private static extern bool IsWindowVisible(IntPtr handle);
        [DllImport("user32.dll", EntryPoint="GetWindowLongW")] private static extern int GetWindowLong(IntPtr handle, int index);
        private void Record(string value)
        {
            lock (sync) { if (records.Count < 4000) records.Add(time.ElapsedMilliseconds + "ms " + value); }
        }
        private void Save()
        {
            string[] snapshot;
            lock (sync) { snapshot = records.ToArray(); }
            try { File.WriteAllLines(path, snapshot, Encoding.UTF8); saveFailure = null; }
            catch (IOException error) { saveFailure = error.GetType().FullName; }
            catch (UnauthorizedAccessException error) { saveFailure = error.GetType().FullName; }
        }
        public override ToolStripMenuItem GetMenuItem(PluginMenuType type)
        {
            if (type != PluginMenuType.Main) return null;
            ToolStripMenuItem item = new ToolStripMenuItem("KeeTheme-Zeichenprotokoll: Speicherort anzeigen");
            item.Click += delegate { Save(); MessageBox.Show("Protokoll: " + path + (saveFailure == null ? "" : "\r\nSchreibfehler: " + saveFailure), "KeeTheme-Diagnose"); };
            return item;
        }
        public override void Terminate()
        {
            GlobalWindowManager.WindowAdded -= WindowAdded;
            foreach (Control control in attached)
            {
                control.HandleCreated -= OnHandleCreated;
                Form form = control as Form;
                if (form != null) { form.Shown -= OnShown; form.FormClosed -= OnClosed; }
            }
            foreach (PaintWindow window in windows) window.Detach();
            Save();
        }
    }
    internal sealed class PaintWindow : NativeWindow
    {
        private readonly Control control;
        private readonly Action<string> record;
        private int paints, erases, enables;
        internal PaintWindow(Control value, Action<string> write)
        {
            control = value; record = write; AssignHandle(control.Handle);
            control.HandleDestroyed += Destroyed;
        }
        private void Destroyed(object sender, EventArgs e) { ReleaseHandle(); }
        internal void Detach() { control.HandleDestroyed -= Destroyed; ReleaseHandle(); }
        protected override void WndProc(ref Message message)
        {
            bool trace = (message.Msg == 15 && paints++ < 3) || (message.Msg == 20 && erases++ < 3) || (message.Msg == 10 && enables++ < 3);
            if (trace) record("Before message=0x" + message.Msg.ToString("X") + " " + KeeThemePaintTraceExt.State(control));
            base.WndProc(ref message);
            if (trace) record("After message=0x" + message.Msg.ToString("X") + " " + KeeThemePaintTraceExt.State(control));
        }
    }
}
