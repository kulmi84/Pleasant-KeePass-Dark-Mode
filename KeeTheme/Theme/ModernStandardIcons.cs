using System.Drawing;
using KeePassLib;

namespace KeeTheme.Theme
{
    internal static class ModernStandardIcons
    {
        internal static bool Draw(Graphics g, Rectangle bounds, int index, Color color)
        {
            string name;
            switch ((PwIcon)index)
            {
                case PwIcon.Key: case PwIcon.MultiKeys: case PwIcon.UserKey: name = "m_tbCopyPassword"; break;
                case PwIcon.Folder: case PwIcon.FolderOpen: case PwIcon.FolderPackage: case PwIcon.MarkedDirectory: name = "m_tbOpenDatabase"; break;
                case PwIcon.UserCommunication: case PwIcon.Identity: name = "m_tbCopyUserName"; break;
                case PwIcon.World: case PwIcon.WorldSocket: case PwIcon.WorldStar: case PwIcon.WorldComputer: name = "m_tbOpenUrl"; break;
                case PwIcon.TerminalEncrypted: case PwIcon.PaperLocked: name = "m_tbLockWorkspace"; break;
                case PwIcon.Clock: case PwIcon.Expired: name = "m_tbViewsShowExpired"; break;
                case PwIcon.List: case PwIcon.ProgramIcons: name = "m_tbEntryViewsDropDown"; break;
                case PwIcon.PaperNew: case PwIcon.Notepad: case PwIcon.Note: name = "m_tbNewDatabase"; break;
                case PwIcon.NetworkServer: name = "standardServer"; break;
                case PwIcon.Home: name = "standardHome"; break;
                case PwIcon.EMail: case PwIcon.EMailBox: name = "standardMail"; break;
                case PwIcon.Tool: case PwIcon.Settings: case PwIcon.Configuration: name = "standardTool"; break;
                case PwIcon.Monitor: case PwIcon.Screen: name = "standardMonitor"; break;
                case PwIcon.TrashBin: name = "standardTrash"; break;
                default: return DrawRemaining(g, bounds, (PwIcon)index, color);
            }
            return ModernToolbarIcons.Draw(g, bounds, name, color);
        }
        private static bool DrawRemaining(Graphics g, Rectangle bounds, PwIcon icon, Color color)
        {
            if ((int)icon < 0 || icon >= PwIcon.Count || bounds.Width <= 0 || bounds.Height <= 0) return false;
            var state = g.Save();
            try
            {
                g.TranslateTransform(bounds.X,bounds.Y);
                g.ScaleTransform(bounds.Width/20f,bounds.Height/20f);
                g.SmoothingMode=System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
                using(var p=new Pen(color,1.55f))
                {
                    p.StartCap=p.EndCap=System.Drawing.Drawing2D.LineCap.Round;
                    p.LineJoin=System.Drawing.Drawing2D.LineJoin.Round;
                    switch(icon)
                    {
                        case PwIcon.Warning:
                            Poly(g,p,10,2,18,17,2,17,10,2); Line(g,p,10,7,10,11); Line(g,p,10,14,10,14.3f); break;
                        case PwIcon.Parts:
                            Poly(g,p,3,4,7,4,7,2,10,2,10,4,16,4,16,8,18,8,18,11,16,11,16,16,11,16,11,18,8,18,8,16,3,16,3,11,5,11,5,8,3,8,3,4); break;
                        case PwIcon.PaperReady: Document(g,p); Check(g,p,7,11); break;
                        case PwIcon.ClipboardReady:
                            g.DrawRectangle(p,4,4,12,14); g.DrawRectangle(p,7,2,6,4); Check(g,p,6,11); break;
                        case PwIcon.Digicam:
                            Poly(g,p,2,6,6,6,8,3,12,3,14,6,18,6,18,16,2,16,2,6); g.DrawEllipse(p,7,8,6,6); break;
                        case PwIcon.IRCommunication:
                            g.DrawArc(p,2,2,16,16,220,100); g.DrawArc(p,5,6,10,10,220,100); g.DrawArc(p,8,10,4,5,220,100); Line(g,p,10,17,10,17.3f); break;
                        case PwIcon.Energy: case PwIcon.EnergyCareful:
                            Poly(g,p,11,2,4,11,9,11,8,18,16,8,11,8,11,2); break;
                        case PwIcon.Scanner:
                            Poly(g,p,3,10,17,10,18,16,2,16,3,10); Line(g,p,4,10,5,4); Line(g,p,5,4,16,7); Line(g,p,5,13,12,13); break;
                        case PwIcon.CDRom:
                            g.DrawEllipse(p,2,2,16,16); g.DrawEllipse(p,8,8,4,4); Line(g,p,12,5,15,3); Line(g,p,5,16,7,13); break;
                        case PwIcon.Disk:
                            g.DrawRectangle(p,3,3,14,14); g.DrawRectangle(p,6,3,7,5); g.DrawRectangle(p,6,11,8,6); break;
                        case PwIcon.Drive:
                            Poly(g,p,5,3,15,3,18,13,18,17,2,17,2,13,5,3); Line(g,p,2,13,18,13); Line(g,p,14,15,15,15); break;
                        case PwIcon.PaperQ:
                            Document(g,p); g.DrawArc(p,7,8,6,5,180,240); Line(g,p,10,12,10,13); Line(g,p,10,15,10,15.2f); break;
                        case PwIcon.Console:
                            g.DrawRectangle(p,2,3,16,14); Poly(g,p,5,7,8,10,5,13); Line(g,p,11,13,15,13); break;
                        case PwIcon.Printer:
                            g.DrawRectangle(p,2,7,16,8); g.DrawRectangle(p,5,2,10,5); g.DrawRectangle(p,5,12,10,6); Line(g,p,14,10,15,10); break;
                        case PwIcon.Run: Poly(g,p,6,3,17,10,6,17,6,3); break;
                        case PwIcon.Archive:
                            g.DrawRectangle(p,2,3,16,4); g.DrawRectangle(p,4,7,12,11); g.DrawRectangle(p,8,10,4,3); break;
                        case PwIcon.Homebanking:
                            Poly(g,p,2,7,10,2,18,7,2,7); foreach(int x in new int[]{5,10,15}) Line(g,p,x,9,x,15); Line(g,p,2,18,18,18); break;
                        case PwIcon.DriveWindows:
                            g.DrawRectangle(p,2,3,16,14); Line(g,p,10,5,10,14); Line(g,p,5,10,15,10); break;
                        case PwIcon.EMailSearch:
                            g.DrawRectangle(p,2,3,13,10); Poly(g,p,2,4,8,9,15,4); g.DrawEllipse(p,10,10,6,6); Line(g,p,15,15,18,18); break;
                        case PwIcon.PaperFlag:
                            Document(g,p); Line(g,p,7,8,7,15); Poly(g,p,7,8,13,8,11,11,7,11); break;
                        case PwIcon.Memory:
                            g.DrawRectangle(p,5,5,10,10); g.DrawRectangle(p,8,8,4,4);
                            foreach(int v in new int[]{7,10,13}) {Line(g,p,v,2,v,5); Line(g,p,v,15,v,18); Line(g,p,2,v,5,v); Line(g,p,15,v,18,v);} break;
                        case PwIcon.Info:
                            g.DrawEllipse(p,2,2,16,16); Line(g,p,10,9,10,14); Line(g,p,10,6,10,6.2f); break;
                        case PwIcon.Package:
                            Poly(g,p,3,6,10,2,17,6,17,14,10,18,3,14,3,6,10,10,17,6); Line(g,p,10,10,10,18); Line(g,p,6,4,13,8); break;
                        case PwIcon.LockOpen:
                            g.DrawArc(p,7,2,8,10,180,180); g.DrawRectangle(p,3,8,12,9); Line(g,p,9,11,9,14); break;
                        case PwIcon.Checked: Check(g,p,3,9); break;
                        case PwIcon.Pen:
                            Poly(g,p,3,17,4,12,14,2,18,6,8,16,3,17); Line(g,p,12,4,16,8); break;
                        case PwIcon.Thumbnail:
                            g.DrawRectangle(p,2,3,16,14); g.DrawEllipse(p,5,6,3,3); Poly(g,p,3,15,8,10,11,13,14,9,17,13); break;
                        case PwIcon.Book:
                            Poly(g,p,2,4,8,4,10,6,12,4,18,4,18,16,12,16,10,18,8,16,2,16,2,4); Line(g,p,10,6,10,18); break;
                        case PwIcon.Star:
                            Poly(g,p,10,2,12.5f,7,18,8,14,12,15,18,10,15,5,18,6,12,2,8,7.5f,7,10,2); break;
                        case PwIcon.Tux:
                            g.DrawEllipse(p,5,2,10,16); g.DrawEllipse(p,7,8,6,8); Line(g,p,7,6,7,6.2f); Line(g,p,13,6,13,6.2f); Poly(g,p,8,7,10,9,12,7); Line(g,p,3,17,7,17); Line(g,p,13,17,17,17); break;
                        case PwIcon.Feather:
                            g.DrawEllipse(p,7,2,9,13); Line(g,p,3,18,13,5); Line(g,p,6,14,12,14); break;
                        case PwIcon.Apple:
                            g.DrawBezier(p,10,6,2,1,2,14,6,17); g.DrawBezier(p,6,17,8,20,9,16,11,17); g.DrawBezier(p,11,17,14,20,17,15,18,13); g.DrawBezier(p,18,13,13,12,13,8,17,6); g.DrawBezier(p,17,6,14,3,12,6,10,6); g.DrawBezier(p,10,4,10,2,13,1,14,1); break;
                        case PwIcon.Wiki:
                            Poly(g,p,2,5,5,16,10,7,15,16,18,5); break;
                        case PwIcon.Money:
                            g.DrawRectangle(p,2,4,16,12); g.DrawEllipse(p,7,7,6,6); Line(g,p,4,7,4,7.2f); Line(g,p,16,13,16,13.2f); break;
                        case PwIcon.Certificate:
                            g.DrawRectangle(p,3,2,14,12); Line(g,p,6,5,14,5); Line(g,p,6,8,11,8); g.DrawEllipse(p,10,10,6,6); Poly(g,p,11,15,10,19,13,17,16,19,15,15); break;
                        case PwIcon.BlackBerry:
                            g.DrawRectangle(p,5,2,10,16); Line(g,p,8,4,12,4); g.DrawRectangle(p,7,6,6,7); Line(g,p,10,16,10,16.2f); break;
                        default: return false;
                    }
                }
                return true;
            }
            finally {g.Restore(state);}
        }
        private static void Line(Graphics g, Pen p, float x1,float y1,float x2,float y2) {g.DrawLine(p,x1,y1,x2,y2);}
        private static void Poly(Graphics g, Pen p, params float[] xy)
        {
            var points=new PointF[xy.Length/2];
            for(int i=0;i<points.Length;i++) points[i]=new PointF(xy[i*2],xy[i*2+1]);
            g.DrawLines(p,points);
        }
        private static void Document(Graphics g, Pen p)
        {Poly(g,p,4,18,4,2,12,2,16,6,16,18,4,18); Poly(g,p,12,2,12,6,16,6);}
        private static void Check(Graphics g, Pen p, float x,float y)
        {Poly(g,p,x,y,x+4,y+4,x+10,y-3);}
    }
}
