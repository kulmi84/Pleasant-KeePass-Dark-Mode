using System;
using System.IO;
using System.Drawing;
using System.Reflection;
using System.Collections.Generic;
using System.Windows.Forms;
using KeePass;
using KeePass.Plugins;
using KeePass.Forms;
using KeePass.UI;
using KeePassLib;
using KeePassLib.Serialization;
using KeePassLib.Security;
[assembly: System.Reflection.AssemblyProduct("KeePass Plugin")]
namespace APaintProbe {
 public sealed class APaintProbeExt : Plugin {
  private IPluginHost host;
  private string output;
  private List<PaintWindow> windows = new List<PaintWindow>();
  public override bool Initialize(IPluginHost value) {
   host=value; output=Path.Combine(Path.GetDirectoryName(typeof(APaintProbeExt).Assembly.Location), "../trace.txt");
   File.WriteAllText(output, "Synthetic KeePass integration trace\r\n");
   Log("Initialize: main visible="+host.MainWindow.Visible+" opacity="+host.MainWindow.Opacity+NativeState.Read(host.MainWindow));
   foreach(Assembly a in AppDomain.CurrentDomain.GetAssemblies()) if(a.GetName().Name=="KeeTheme") Log("Theme="+a.FullName);
   GlobalWindowManager.WindowAdded += OnWindowAdded;
   host.MainWindow.Shown += delegate { Log("Main shown opacity="+host.MainWindow.Opacity+NativeState.Read(host.MainWindow)); host.MainWindow.BeginInvoke(new MethodInvoker(delegate { Log("Main queued opacity="+host.MainWindow.Opacity+NativeState.Read(host.MainWindow)); Run(); })); };
   return true;
  }
  private void Log(string value) { File.AppendAllText(output, DateTime.UtcNow.ToString("HH:mm:ss.fff")+" "+value+"\r\n"); }
  private void OnWindowAdded(object sender, GwmWindowEventArgs e) {
   Log("WindowAdded "+e.Form.GetType().Name+" visible="+e.Form.Visible+" opacity="+e.Form.Opacity+NativeState.Read(e.Form));
   Attach(e.Form);
   e.Form.Shown += delegate { Log("Shown "+e.Form.GetType().Name+" opacity="+e.Form.Opacity+NativeState.Read(e.Form)); };
  }
  private void Attach(Control c) {
   if(c.IsHandleCreated) windows.Add(new PaintWindow(c,Log));
   else c.HandleCreated += delegate { windows.Add(new PaintWindow(c,Log)); };
   foreach(Control child in c.Controls) Attach(child);
  }
  private void Display(Form form) {
   form.StartPosition=FormStartPosition.Manual;
   form.Location=new Point(-3000,-3000);
   Timer close=new Timer(); close.Interval=500;
   close.Tick += delegate { close.Stop(); form.DialogResult=DialogResult.Cancel; form.Close(); };
   form.Shown += delegate { close.Start(); };
   Log("Before Show "+form.GetType().Name+" visible="+form.Visible+" opacity="+form.Opacity);
   form.ShowDialog(host.MainWindow);
   close.Dispose(); form.Dispose();
  }
  private void Run() {
   try {
    PwDatabase db=new PwDatabase(); db.New(new IOConnectionInfo { Path="Synthetic.kdbx" }, new KeePassLib.Keys.CompositeKey());
    PwEntry entry=new PwEntry(true,true); entry.Strings.Set("Title",new ProtectedString(false,"Synthetic example"));
    db.RootGroup.AddEntry(entry,true);
    PwEntryForm ef=new PwEntryForm(); ef.InitEx(entry,PwEditMode.EditExistingEntry,db,host.MainWindow.ClientIcons,false,false); Display(ef);
    GroupForm gf=new GroupForm(); gf.InitEx(db.RootGroup,host.MainWindow.ClientIcons,db); Display(gf);
    KeyPromptForm kf=new KeyPromptForm(); kf.InitEx(new IOConnectionInfo { Path="Synthetic.kdbx" },false,false); Display(kf);
    db.Close(); Log("DONE");
   } catch(Exception ex) { Log("ERROR "+ex.ToString()); }
   host.MainWindow.Close();
  }
 }
 internal static class NativeState {
  [System.Runtime.InteropServices.DllImport("user32.dll")] private static extern bool IsWindowVisible(IntPtr h);
  [System.Runtime.InteropServices.DllImport("user32.dll")] private static extern bool GetLayeredWindowAttributes(IntPtr h,out uint key,out byte alpha,out uint flags);
  internal static string Read(Form f) {
   uint key,flags; byte alpha;
   if(!GetLayeredWindowAttributes(f.Handle,out key,out alpha,out flags)) alpha=255;
   return " alpha="+alpha+" nativeVisible="+IsWindowVisible(f.Handle);
  }
 }
 internal class PaintWindow : NativeWindow {
  private Control control; private Action<string> log; private int paints;
  internal PaintWindow(Control c,Action<string> write) { control=c; log=write; AssignHandle(c.Handle); c.HandleDestroyed += delegate { ReleaseHandle(); }; }
  protected override void WndProc(ref Message message) {
   bool first=message.Msg==15 && paints++==0;
   if(first) log("FirstPaint "+control.GetType().Name+"/"+control.Name+" visible="+control.Visible+" opacity="+control.FindForm().Opacity+NativeState.Read(control.FindForm())+" background="+control.BackColor.ToArgb().ToString("X8"));
   base.WndProc(ref message);
  }
 }
}


