using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Windows.Forms;
using KeePass.UI.ToolStripRendering;

namespace KeeTheme.Theme
{
    class CustomToolStripRenderer : ProExtTsr
    {
        private readonly CustomTheme _customTheme;
        protected override bool EnsureTextContrast { get { return false; } }
        public CustomToolStripRenderer(CustomTheme theme, ProfessionalColorTable table) : base(table)
        { _customTheme = theme; }

        protected override void OnRenderItemText(ToolStripItemTextRenderEventArgs e)
        {
            if (!e.Item.Enabled && !_customTheme.MenuItem.DisabledForeColor.IsEmpty)
                e.TextColor = _customTheme.MenuItem.DisabledForeColor;
            else if (e.Item.Pressed || e.Item.Selected)
                e.TextColor = _customTheme.MenuItem.HighlightColor;
            base.OnRenderItemText(e);
        }

        private static bool IsMoreCommands(string text)
        {
            var property = typeof(KeePass.Resources.KPRes).GetProperty("MoreCommands");
            return property != null && text == (string)property.GetValue(null, null);
        }

        protected override void OnRenderItemImage(ToolStripItemImageRenderEventArgs e)
        {
            var owner = e.Item.Owner;
            var dropdown = owner as ToolStripDropDown;
            bool extrasMenu = e.Item.Name == "m_menuTools";
            while (dropdown != null && dropdown.OwnerItem != null)
            {
                if (dropdown.OwnerItem.Name == "m_menuTools") extrasMenu = true;
                owner = dropdown.OwnerItem.Owner;
                dropdown = owner as ToolStripDropDown;
            }
            var context = owner as ContextMenuStrip;
            var form = context != null && context.SourceControl != null ? context.SourceControl.FindForm() : owner == null ? null : owner.FindForm();
            bool mainMenu = form != null && form.GetType().FullName == "KeePass.Forms.MainForm";
            if (context != null && (context.Name == "m_ctxGroupList" || context.Name == "m_ctxPwList")) mainMenu = true;
            string name = mainMenu && context != null && string.IsNullOrEmpty(e.Item.Name) && IsMoreCommands(e.Item.Text) ? "modernMoreCommands" : e.Item.Name;
            var color = e.Item.Enabled ? _customTheme.MenuItem.ForeColor : _customTheme.MenuItem.DisabledForeColor;
            if (color.IsEmpty) color = Color.FromArgb(190, 190, 190);
            if (_customTheme.MenuItem.ModernIcons && (mainMenu || extrasMenu))
            {
                if (ModernToolbarIcons.Draw(e.Graphics, e.ImageRectangle, name, color)) return;
                // Preserve third-party artwork and shared images; render only the
                // Extras-menu copy in grayscale instead of replacing plugin logos.
                if (extrasMenu && e.Image != null)
                {
                    using(var attributes=new ImageAttributes())
                    {
                        attributes.SetColorMatrix(new ColorMatrix(new float[][] {
                            new float[]{.299f,.299f,.299f,0,0},new float[]{.587f,.587f,.587f,0,0},
                            new float[]{.114f,.114f,.114f,0,0},new float[]{0,0,0,e.Item.Enabled?1f:.45f,0},new float[]{0,0,0,0,1}}));
                        e.Graphics.DrawImage(e.Image,e.ImageRectangle,0,0,e.Image.Width,e.Image.Height,GraphicsUnit.Pixel,attributes);
                    }
                    return;
                }
            }
            base.OnRenderItemImage(e);
        }

        protected override void OnRenderItemCheck(ToolStripItemImageRenderEventArgs e)
        {
            if (!_customTheme.MenuItem.ModernIcons) { base.OnRenderItemCheck(e); return; }
            var bounds=e.ImageRectangle;
            using(var pen=new Pen(e.Item.Enabled?_customTheme.MenuItem.ForeColor:_customTheme.MenuItem.DisabledForeColor,1.7f))
            {
                pen.StartCap=pen.EndCap=LineCap.Round;
                e.Graphics.DrawLines(pen,new PointF[]{new PointF(bounds.Left+bounds.Width*.2f,bounds.Top+bounds.Height*.5f),new PointF(bounds.Left+bounds.Width*.43f,bounds.Top+bounds.Height*.75f),new PointF(bounds.Left+bounds.Width*.82f,bounds.Top+bounds.Height*.23f)});
            }
        }

        protected override void OnRenderImageMargin(ToolStripRenderEventArgs e)
        {
            if (!_customTheme.MenuItem.ModernIcons) { base.OnRenderImageMargin(e); return; }
            using(var brush = new SolidBrush(_customTheme.MenuItem.BackColor)) e.Graphics.FillRectangle(brush,e.AffectedBounds);
        }
        protected override void OnRenderToolStripBorder(ToolStripRenderEventArgs e)
        {
            if (!_customTheme.MenuItem.ModernIcons || !(e.ToolStrip is ToolStripDropDown)) { base.OnRenderToolStripBorder(e); return; }
            using(var pen = new Pen(Color.FromArgb(65,65,65))) e.Graphics.DrawRectangle(pen,0,0,e.ToolStrip.Width-1,e.ToolStrip.Height-1);
        }
        protected override void OnRenderMenuItemBackground(ToolStripItemRenderEventArgs e)
        {
            if (!_customTheme.MenuItem.ModernIcons) { base.OnRenderMenuItemBackground(e); return; }
            if (!e.Item.Enabled || (!e.Item.Selected && !e.Item.Pressed)) return;
            using(var brush = new SolidBrush(Color.FromArgb(56,101,138))) e.Graphics.FillRectangle(brush,new Rectangle(3,1,e.Item.Width-6,e.Item.Height-2));
        }
        private bool DrawToolbarButton(ToolStripItemRenderEventArgs e, bool isChecked)
        {
            if (!_customTheme.MenuItem.ModernIcons || e.ToolStrip is ToolStripDropDown || e.ToolStrip is MenuStrip)
                return false;
            if (!e.Item.Selected && !e.Item.Pressed && !isChecked) return true;
            var rect = new RectangleF(1, 1, e.Item.Width - 2, e.Item.Height - 2);
            if (rect.Width <= 0 || rect.Height <= 0) return true;
            float radius = System.Math.Min(4f * e.Item.Height / 24f, System.Math.Min(rect.Width, rect.Height) / 2);
            var state = e.Graphics.Save();
            try
            {
                e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
                using (var path = new GraphicsPath())
                using (var brush = new SolidBrush(e.Item.Pressed ? Color.FromArgb(73,73,78) : Color.FromArgb(62,62,66)))
                {
                    float d = radius * 2;
                    path.AddArc(rect.X, rect.Y, d, d, 180, 90);
                    path.AddArc(rect.Right-d, rect.Y, d, d, 270, 90);
                    path.AddArc(rect.Right-d, rect.Bottom-d, d, d, 0, 90);
                    path.AddArc(rect.X, rect.Bottom-d, d, d, 90, 90);
                    path.CloseFigure();
                    e.Graphics.FillPath(brush, path);
                }
            }
            finally { e.Graphics.Restore(state); }
            return true;
        }

        protected override void OnRenderButtonBackground(ToolStripItemRenderEventArgs e)
        {
            var button = e.Item as ToolStripButton;
            if (!DrawToolbarButton(e, button != null && button.Checked)) base.OnRenderButtonBackground(e);
        }
        protected override void OnRenderDropDownButtonBackground(ToolStripItemRenderEventArgs e)
        { if (!DrawToolbarButton(e, false)) base.OnRenderDropDownButtonBackground(e); }
        protected override void OnRenderSplitButtonBackground(ToolStripItemRenderEventArgs e)
        {
            if (!DrawToolbarButton(e, false)) { base.OnRenderSplitButtonBackground(e); return; }
            var button = (ToolStripSplitButton)e.Item;
            OnRenderArrow(new ToolStripArrowRenderEventArgs(e.Graphics, button, button.DropDownButtonBounds,
                _customTheme.MenuItem.ForeColor, ArrowDirection.Down));
        }
        protected override void OnRenderArrow(ToolStripArrowRenderEventArgs e)
        {
            if (_customTheme.MenuItem.ModernIcons)
                e.ArrowColor = e.Item.Enabled ? _customTheme.MenuItem.ForeColor : _customTheme.MenuItem.DisabledForeColor;
            base.OnRenderArrow(e);
        }
        protected override void OnRenderSeparator(ToolStripSeparatorRenderEventArgs e)
        {
            if (!_customTheme.MenuItem.ModernIcons) { base.OnRenderSeparator(e); return; }
            using (var pen = new Pen(Color.FromArgb(65,65,69)))
            {
                if (e.Vertical) e.Graphics.DrawLine(pen,e.Item.Width/2,5,e.Item.Width/2,e.Item.Height-5);
                else e.Graphics.DrawLine(pen,6,e.Item.Height/2,e.Item.Width-6,e.Item.Height/2);
            }
        }
        protected override void OnRenderToolStripBackground(ToolStripRenderEventArgs e)
        {
            if (e.ToolStrip is MenuStrip || _customTheme.MenuItem.ModernIcons)
            {
                using (var brush = new SolidBrush(_customTheme.MenuItem.BackColor))
                    e.Graphics.FillRectangle(brush,e.AffectedBounds);
            }
            else base.OnRenderToolStripBackground(e);
        }
    }
}
