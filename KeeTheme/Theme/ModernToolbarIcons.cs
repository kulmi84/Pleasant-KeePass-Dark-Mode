using System.Drawing;
using System.Drawing.Drawing2D;

namespace KeeTheme.Theme
{
    // Original vector artwork. No database images or shared image lists are changed.
    internal static class ModernToolbarIcons
    {
        internal static bool Draw(Graphics g, Rectangle bounds, string name, Color color)
        {
            // KeePass context-menu copies use m_ctx instead of m_menu.
            if (name != null && (name.StartsWith("m_ctxGroup") || name.StartsWith("m_ctxEntry")) && name != "m_ctxGroupFind") name = "m_menu" + name.Substring(5);
            string glyph;
            switch (name)
            {
                case "m_menuToolsPwGenerator": glyph = "key"; break;
                case "m_menuToolsGeneratePwList": glyph = "views"; break;
                case "m_menuToolsTanWizard": glyph = "wand"; break;
                case "m_menuToolsTriggers": glyph = "trigger"; break;
                case "m_menuToolsPlugins": glyph = "plugin"; break;
                case "m_menuToolsOptions": case "m_menuToolsOptionsEnf": glyph = "settings"; break;
                case "m_tbNewDatabase": case "m_menuFileNew": glyph = "new"; break;
                case "m_tbOpenDatabase": case "m_menuFileOpen": glyph = "open"; break;
                case "m_tbSaveDatabase": case "m_menuFileSave": glyph = "save"; break;
                case "m_tbSaveAll": glyph = "saveAll"; break;
                case "m_tbAddEntry": case "m_tbAddEntryDefault": glyph = "add"; break;
                case "m_tbCopyUserName": glyph = "user"; break;
                case "m_tbCopyPassword": glyph = "key"; break;
                case "m_tbOpenUrl": case "m_tbOpenUrlDefault": glyph = "globe"; break;
                case "m_tbCopyUrl": glyph = "copy"; break;
                case "m_tbAutoType": glyph = "keyboard"; break;
                case "m_tbFind": glyph = "search"; break;
                case "m_tbEntryViewsDropDown": case "m_tbViewsShowAll": glyph = "views"; break;
                case "m_tbViewsShowExpired": glyph = "clock"; break;
                case "m_tbLockWorkspace": glyph = "lock"; break;
                case "m_tbCloseTab": glyph = "close"; break;
                case "m_menuGroupAdd": glyph = "folderAdd"; break;
                case "m_menuGroupEdit": glyph = "folderEdit"; break;
                case "m_menuGroupDelete": glyph = "trash"; break;
                case "m_menuGroupEmptyRB": glyph = "trash"; break;
                case "m_menuGroupDuplicate": case "m_menuEntryDuplicate":
                case "m_menuGroupClipCopy": case "m_menuGroupClipCopyPlain":
                case "m_menuEntryClipCopy": case "m_menuEntryClipCopyPlain":
                case "m_menuEntryCopyUrl": glyph = "copy"; break;
                case "modernMoreCommands": glyph = "more"; break;
                case "m_ctxGroupFind": glyph = "search"; break;
                case "m_menuGroupMoveToTop": case "m_menuEntryMoveToTop": glyph = "top"; break;
                case "m_menuGroupMoveOneUp": case "m_menuEntryMoveOneUp": glyph = "up"; break;
                case "m_menuGroupMoveOneDown": case "m_menuEntryMoveOneDown": glyph = "down"; break;
                case "m_menuGroupMoveToBottom": case "m_menuEntryMoveToBottom": glyph = "bottom"; break;
                case "m_menuGroupMoveToPreviousParent": case "m_menuEntryMoveToPreviousParent": glyph = "back"; break;
                case "m_menuGroupSort": case "m_menuGroupSortRec": glyph = "sort"; break;
                case "m_menuGroupExpand": glyph = "expand"; break;
                case "m_menuGroupCollapse": glyph = "collapse"; break;
                case "m_menuGroupDX": case "m_menuEntryDX": glyph = "export"; break;
                case "m_menuGroupExport": case "m_menuEntryExport": glyph = "export"; break;
                case "m_menuGroupPrint": case "m_menuEntryPrint": glyph = "print"; break;
                case "m_menuGroupClipPaste": case "m_menuEntryClipPaste": glyph = "paste"; break;
                case "m_menuEntryCopyUserName": glyph = "user"; break;
                case "m_menuEntryCopyPassword": glyph = "key"; break;
                case "m_menuEntryOpenUrl": glyph = "globe"; break;
                case "m_menuEntryPerformAutoType": glyph = "keyboard"; break;
                case "m_menuEntryAdd": glyph = "add"; break;
                case "m_menuEntryEdit": glyph = "edit"; break;
                case "m_menuEntryDelete": glyph = "trash"; break;
                case "standardServer": glyph = "server"; break;
                case "standardHome": glyph = "home"; break;
                case "standardMail": glyph = "mail"; break;
                case "standardTool": glyph = "tool"; break;
                case "standardMonitor": glyph = "monitor"; break;
                case "standardTrash": glyph = "trash"; break;
                default: return false;
            }
            if (bounds.Width <= 0 || bounds.Height <= 0) return false;
            var state = g.Save();
            try
            {
                g.TranslateTransform(bounds.X, bounds.Y);
                g.ScaleTransform(bounds.Width / 20f, bounds.Height / 20f);
                g.SmoothingMode = SmoothingMode.AntiAlias;
                using (var p = new Pen(color, 1.55f))
                {
                    p.StartCap = p.EndCap = LineCap.Round;
                    p.LineJoin = LineJoin.Round;
                    switch (glyph)
                    {
                        case "wand": g.DrawLine(p,4,17,14,7);g.DrawLine(p,11,10,14,13);g.DrawLine(p,5,2,5,6);g.DrawLine(p,3,4,7,4);g.DrawLine(p,16,2,16,6);g.DrawLine(p,14,4,18,4);break;
                        case "trigger": g.DrawRectangle(p,2,3,5,5);g.DrawRectangle(p,13,12,5,5);g.DrawLines(p,new PointF[]{new PointF(7,5),new PointF(15,5),new PointF(15,12)});g.DrawLines(p,new PointF[]{new PointF(12,9),new PointF(15,12),new PointF(18,9)});break;
                        case "plugin": g.DrawLines(p,new PointF[]{new PointF(6,3),new PointF(6,8),new PointF(3,8),new PointF(3,13),new PointF(8,13),new PointF(8,17),new PointF(13,17),new PointF(13,13),new PointF(17,13),new PointF(17,8),new PointF(13,8),new PointF(13,3),new PointF(6,3)});g.DrawArc(p,7,1,5,5,180,180);break;
                        case "settings":
                            g.DrawEllipse(p,5,5,10,10);g.DrawEllipse(p,8,8,4,4);
                            for(int i=0;i<8;i++){double angle=i*System.Math.PI/4;g.DrawLine(p,10+(float)System.Math.Cos(angle)*5,10+(float)System.Math.Sin(angle)*5,10+(float)System.Math.Cos(angle)*8,10+(float)System.Math.Sin(angle)*8);}break;
                        case "more": g.DrawLine(p,4,10,4.3f,10);g.DrawLine(p,10,10,10.3f,10);g.DrawLine(p,16,10,16.3f,10);break;
                        case "folderAdd": case "folderEdit":
                            g.DrawLines(p,new PointF[]{new PointF(3,16),new PointF(3,5),new PointF(8,5),new PointF(10,7),new PointF(17,7),new PointF(17,10)});
                            g.DrawLine(p,3,16,10,16);
                            if(glyph == "folderAdd") { g.DrawLine(p,14,11,14,17); g.DrawLine(p,11,14,17,14); }
                            else { g.DrawLine(p,11,17,17,11); g.DrawLine(p,11,17,14,16); } break;
                        case "edit": g.DrawPolygon(p,new PointF[]{new PointF(3,17),new PointF(4,13),new PointF(14,3),new PointF(17,6),new PointF(7,16)}); g.DrawLine(p,12,5,15,8); break;
                        case "top": g.DrawLine(p,4,3,16,3); goto case "up";
                        case "up": g.DrawLines(p,new PointF[]{new PointF(4,12),new PointF(10,6),new PointF(16,12)}); g.DrawLine(p,10,6,10,17); break;
                        case "bottom": g.DrawLine(p,4,17,16,17); goto case "down";
                        case "down": g.DrawLines(p,new PointF[]{new PointF(4,8),new PointF(10,14),new PointF(16,8)}); g.DrawLine(p,10,3,10,14); break;
                        case "back": g.DrawLines(p,new PointF[]{new PointF(8,4),new PointF(3,9),new PointF(8,14)}); g.DrawLines(p,new PointF[]{new PointF(3,9),new PointF(13,9),new PointF(17,13),new PointF(17,17)}); break;
                        case "sort": g.DrawLine(p,5,3,5,17); g.DrawLines(p,new PointF[]{new PointF(2,14),new PointF(5,17),new PointF(8,14)}); g.DrawLine(p,11,4,14,4);g.DrawLine(p,11,9,16,9);g.DrawLine(p,11,14,18,14); break;
                        case "expand": case "collapse":
                            g.DrawRectangle(p,3,5,14,12); g.DrawLine(p,3,5,8,5); g.DrawLine(p,8,5,10,7); g.DrawLine(p,7,12,13,12);
                            if(glyph == "expand")g.DrawLine(p,10,9,10,15); break;
                        case "export": g.DrawLines(p,new PointF[]{new PointF(4,4),new PointF(4,17),new PointF(16,17),new PointF(16,12)}); g.DrawLine(p,9,11,17,3);g.DrawLines(p,new PointF[]{new PointF(11,3),new PointF(17,3),new PointF(17,9)}); break;
                        case "print": g.DrawRectangle(p,5,2,10,5);g.DrawRectangle(p,2,7,16,8);g.DrawRectangle(p,5,12,10,6);break;
                        case "paste": g.DrawRectangle(p,4,4,12,14);g.DrawRectangle(p,7,2,6,4);g.DrawLine(p,7,10,13,10);g.DrawLine(p,7,14,12,14);break;
                        case "new":
                            g.DrawLines(p, new PointF[] { new PointF(4,17), new PointF(4,3), new PointF(11,3), new PointF(16,8), new PointF(16,17), new PointF(4,17) });
                            g.DrawLines(p, new PointF[] { new PointF(11,3), new PointF(11,8), new PointF(16,8) });
                            g.DrawLine(p,7,12,13,12); g.DrawLine(p,10,9,10,15); break;
                        case "open":
                            g.DrawLines(p, new PointF[] { new PointF(3,16), new PointF(3,5), new PointF(8,5), new PointF(10,7), new PointF(17,7) });
                            g.DrawPolygon(p,new PointF[] { new PointF(3,16),new PointF(6,9),new PointF(18,9),new PointF(15,16) }); break;
                        case "saveAll": g.DrawLines(p,new PointF[] { new PointF(2,7),new PointF(2,18),new PointF(13,18) }); goto case "save";
                        case "save":
                            g.DrawPolygon(p,new PointF[] {new PointF(5,3),new PointF(14,3),new PointF(17,6),new PointF(17,15),new PointF(5,15)});
                            g.DrawRectangle(p,8,3,5,4); g.DrawRectangle(p,8,10,6,5); break;
                        case "add": g.DrawLine(p,10,4,10,16); g.DrawLine(p,4,10,16,10); break;
                        case "user": g.DrawEllipse(p,7,3,6,6); g.DrawArc(p,4,11,12,12,180,180); break;
                        case "key": g.DrawEllipse(p,3,3,7,7); g.DrawLine(p,9,9,17,17); g.DrawLine(p,12,12,14,10); g.DrawLine(p,15,15,17,13); break;
                        case "globe": g.DrawEllipse(p,3,3,14,14); g.DrawEllipse(p,7,3,6,14); g.DrawLine(p,3,10,17,10); break;
                        case "copy": g.DrawLines(p,new PointF[] {new PointF(6,13),new PointF(3,13),new PointF(3,3),new PointF(13,3),new PointF(13,6)}); g.DrawRectangle(p,7,7,10,10); break;
                        case "keyboard":
                            g.DrawRectangle(p,2,5,16,11);
                            for(int y=8;y<=10;y+=2) for(int x=5;x<=15;x+=3) g.DrawLine(p,x,y,x+.3f,y);
                            g.DrawLine(p,6,13,14,13); break;
                        case "search": g.DrawEllipse(p,3,3,10,10); g.DrawLine(p,12,12,17,17); break;
                        case "views":
                            for(int y=4;y<=16;y+=6) { g.DrawLine(p,3,y,4,y); g.DrawLine(p,8,y,17,y); } break;
                        case "clock": g.DrawEllipse(p,3,3,14,14); g.DrawLine(p,10,6,10,10); g.DrawLine(p,10,10,13,12); break;
                        case "lock": g.DrawArc(p,6,2,8,10,180,180); g.DrawRectangle(p,4,8,12,9); g.DrawLine(p,10,11,10,14); break;
                        case "server": g.DrawRectangle(p,3,3,14,6); g.DrawRectangle(p,3,11,14,6); g.DrawLine(p,6,6,7,6); g.DrawLine(p,6,14,7,14); break;
                        case "home": g.DrawLines(p,new PointF[]{new PointF(2,9),new PointF(10,3),new PointF(18,9)}); g.DrawLines(p,new PointF[]{new PointF(4,8),new PointF(4,17),new PointF(16,17),new PointF(16,8)}); g.DrawRectangle(p,8,11,4,6); break;
                        case "mail": g.DrawRectangle(p,2,4,16,12); g.DrawLines(p,new PointF[]{new PointF(2,5),new PointF(10,11),new PointF(18,5)}); break;
                        case "tool": g.DrawLines(p,new PointF[]{new PointF(5,3),new PointF(8,6),new PointF(6,8),new PointF(3,5),new PointF(3,9),new PointF(7,11),new PointF(14,18),new PointF(18,14),new PointF(11,7),new PointF(9,3),new PointF(5,3)}); break;
                        case "monitor": g.DrawRectangle(p,2,3,16,11); g.DrawLine(p,10,14,10,17); g.DrawLine(p,6,17,14,17); break;
                        case "trash": g.DrawLine(p,3,5,17,5); g.DrawLine(p,7,2,13,2); g.DrawLines(p,new PointF[]{new PointF(5,5),new PointF(6,17),new PointF(14,17),new PointF(15,5)}); g.DrawLine(p,9,8,9,14); g.DrawLine(p,12,8,12,14); break;
                        case "close": g.DrawLine(p,5,5,15,15); g.DrawLine(p,5,15,15,5); break;
                    }
                }
            }
            finally { g.Restore(state); }
            return true;
        }
    }
}
