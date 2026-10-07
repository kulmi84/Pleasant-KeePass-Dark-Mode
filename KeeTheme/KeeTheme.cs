using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Windows.Forms.VisualStyles;
using KeePass.App;
using KeePass.UI;
using KeePassLib.Utility;
using KeePassLib;
using KeeTheme.Decorators;
using KeeTheme.Options;
using KeeTheme.Theme;

namespace KeeTheme
{
	internal class KeeTheme
	{
		private readonly KeeThemeOptions _options;
		private readonly CustomTheme _defaultTheme;

		private ITheme _customTheme;
		private ITheme _theme;
		private bool _enabled;
        private Image _bannerArtwork;
        private readonly Dictionary<Control, IDisposable> _fieldBorders = new Dictionary<Control, IDisposable>();
        private readonly Dictionary<ComboBox, DrawMode> _comboDrawModes = new Dictionary<ComboBox, DrawMode>();
        private readonly Dictionary<ToolStrip, CenteredSearchDecorator> _centeredSearch = new Dictionary<ToolStrip, CenteredSearchDecorator>();
        private readonly Dictionary<ToolStripItem, bool> _toolbarAvailable = new Dictionary<ToolStripItem, bool>();
        private readonly Dictionary<ToolStripItem, Size> _searchSize = new Dictionary<ToolStripItem, Size>();
        private readonly Dictionary<ToolStripItem, bool> _searchAutoSize = new Dictionary<ToolStripItem, bool>();
        private readonly Dictionary<ToolStripItem, Padding> _toolbarPadding = new Dictionary<ToolStripItem, Padding>();

		public bool UseModernIcons { get { return _enabled && _theme.MenuItem.ModernIcons; } }

        public bool Enabled
		{
			get { return _enabled; }
			set { SetEnable(value); }
		}

		public string Name
		{
			get { return _customTheme.Name; }
		}

		public KeeTheme(KeeThemeOptions options)
		{
			_options = options;
			_defaultTheme = CustomTheme.GetDefaultTheme();
			_customTheme = GetCustomTheme();
			_theme = _defaultTheme;
		}

		private void SetEnable(bool enable)
		{
			_enabled = enable;

			if (_enabled)
				_customTheme = GetCustomTheme();

			_theme = _enabled ? _customTheme : _defaultTheme;

			ToolStripManager.Renderer = _theme.ToolStripRenderer;
			ObjectListViewDecorator.Initialize();
			KnownColorsDecorator.Apply(_theme, _enabled);

			ApplyOther();
		}

		private ITheme GetCustomTheme()
		{
			var templateFile = TemplateReader.Get(_options.Template) ?? TemplateReader.GetDefaultTemplate();
			var themeTemplate = new CustomThemeTemplate(templateFile);
			return new CustomTheme(themeTemplate);
		}

		private void ApplyOther()
		{
			var colorControlNormalField =
				typeof(AppDefs).GetField("ColorControlNormal", BindingFlags.Static | BindingFlags.Public);
			var colorControlDisabledField =
				typeof(AppDefs).GetField("ColorControlDisabled", BindingFlags.Static | BindingFlags.Public);
			var colorEditError =
				typeof(AppDefs).GetField("ColorEditError", BindingFlags.Static | BindingFlags.Public);

			if (colorControlNormalField != null)
				colorControlNormalField.SetValue(null, _theme.Other.ControlNormalColor);

			if (colorControlDisabledField != null)
				colorControlDisabledField.SetValue(null, _theme.Other.ControlDisabledColor);

			if (colorEditError != null)
				colorEditError.SetValue(null, _theme.Other.ColorEditError);
		}

		public void Apply(Control control)
		{
			if (control.InvokeRequired)
			{
				control.Invoke(new MethodInvoker(() => Apply(control)));
			}

			if (!(control is ToolStrip))
			{
				control.BackColor = _theme.Control.BackColor;
				control.ForeColor = _theme.Control.ForeColor;
			}

			var form = control as Form;
			if (form != null) Apply(form);

			var userControl = control as UserControl;
			if (userControl != null) Apply(userControl);

			var dataGridView = control as DataGridView;
			if (dataGridView != null) Apply(dataGridView);

			var button = control as Button;
			if (button != null) Apply(button);

			var treeView = control as TreeView;
			if (treeView != null) Apply(treeView);

			var richTextBox = control as RichTextBox;
			if (richTextBox != null) Apply(richTextBox);

			var linkLabel = control as LinkLabel;
			if (linkLabel != null) Apply(linkLabel);

			var listView = control as ListView;
			if (listView != null) Apply(listView);

			var secureTextBoxEx = control as SecureTextBoxEx;
			if (secureTextBoxEx != null) Apply(secureTextBoxEx);

			var hotKeyControlEx = control as HotKeyControlEx;
			if (hotKeyControlEx != null) Apply(hotKeyControlEx);

			var toolStrip = control as ToolStrip;
			if (toolStrip != null) Apply(toolStrip);

			var menuStrip = control as MenuStrip;
			if (menuStrip != null) Apply(menuStrip);

			var contextMenuStrip = control as ContextMenuStrip;
			if (contextMenuStrip != null) Apply(contextMenuStrip);

			var statusStrip = control as StatusStrip;
			if (statusStrip != null) Apply(statusStrip);

			var tabControl = control as TabControl;
			if (tabControl != null) Apply(tabControl);

			var tabPage = control as TabPage;
			if (tabPage != null) Apply(tabPage);

			var qualityProgressBar = control as QualityProgressBar;
			if (qualityProgressBar != null) Apply(qualityProgressBar);

			var comboBox = control as ComboBox;
			if (comboBox != null) Apply(comboBox);

			var checkBox = control as CheckBox;
			if (checkBox != null) Apply(checkBox);

			var propertyGrid = control as PropertyGrid;
			if (propertyGrid != null) Apply(propertyGrid);

			OverrideResetBackground(control);
			OverrideScrollBarsSetExplorerTheme(control);
			if (control is TextBoxBase || control is DateTimePicker || control is ComboBox)
            {
                var target = control is RichTextBox && control.Parent is RichTextBoxDecorator ? control.Parent : control;
                var owner = target.FindForm();
                IDisposable border;
                bool modern = UseModernIcons && owner != null && (owner.GetType().FullName == "KeePass.Forms.PwEntryForm" || owner.GetType().FullName == "KeePass.Forms.KeyPromptForm" || owner.GetType().FullName == "KeePass.Forms.GroupForm" || owner.GetType().FullName == "KeePass.Forms.DatabaseSettingsForm");
                if (modern && !_fieldBorders.ContainsKey(target))
                {
                    _fieldBorders.Add(target, new CenteredSearchDecorator.SearchBorderWindow(target, true));
                    target.Disposed += delegate { if (_fieldBorders.TryGetValue(target, out border)) { border.Dispose(); _fieldBorders.Remove(target); } };
                }
                else if (!modern && _fieldBorders.TryGetValue(target, out border))
                {
                    border.Dispose(); _fieldBorders.Remove(target);
                }
            }
            var datePicker = control as DateTimePicker;
            if (datePicker != null)
            {
                datePicker.DropDown -= HandleModernCalendarDropDown;
                if (UseModernIcons) datePicker.DropDown += HandleModernCalendarDropDown;
            }
            var banner = control as PictureBox;
            if (banner != null && banner.Name == "m_bannerImage")
            {
                banner.Paint -= HandleModernBannerPaint;
                var owner = banner.FindForm();
                if (UseModernIcons && owner != null && (owner.GetType().FullName == "KeePass.Forms.KeyPromptForm" || owner.GetType().FullName == "KeePass.Forms.PwEntryForm" || owner.GetType().FullName == "KeePass.Forms.GroupForm"))
                    banner.Paint += HandleModernBannerPaint;
                banner.Invalidate();
            }
		}

        private void HandleModernBannerPaint(object sender, PaintEventArgs e)
        {
            if (!UseModernIcons) return;
            var banner = (PictureBox)sender;
            bool group = banner.FindForm().GetType().FullName == "KeePass.Forms.GroupForm";
            bool unlock = banner.FindForm().GetType().FullName == "KeePass.Forms.KeyPromptForm";
            using (var brush = new SolidBrush(_theme.Control.BackColor)) e.Graphics.FillRectangle(brush, banner.ClientRectangle);
            if (_bannerArtwork == null)
                using (var stream = typeof(KeeTheme).Assembly.GetManifestResourceStream("KeeTheme.Resources.ModernBanner.png"))
                    if (stream != null) using (var image = Image.FromStream(stream)) _bannerArtwork = new Bitmap(image);
            if (_bannerArtwork != null)
            {
                int width = Math.Min(banner.Width/3, banner.Height*2);
                var target = new Rectangle(banner.Width-width,0,width,banner.Height-1);
                int sourceWidth = Math.Min(_bannerArtwork.Width, _bannerArtwork.Height*2);
                using (var attributes = new System.Drawing.Imaging.ImageAttributes())
                {
                    var matrix = new System.Drawing.Imaging.ColorMatrix(); matrix.Matrix33 = 0.5f;
                    attributes.SetColorMatrix(matrix);
                    e.Graphics.DrawImage(_bannerArtwork,target,_bannerArtwork.Width-sourceWidth,0,sourceWidth,_bannerArtwork.Height,GraphicsUnit.Pixel,attributes);
                }
                var fade = new Rectangle(target.Left,0,Math.Max(1,width/3),target.Height);
                using (var brush = new System.Drawing.Drawing2D.LinearGradientBrush(fade,_theme.Control.BackColor,Color.FromArgb(0,_theme.Control.BackColor),0f))
                    e.Graphics.FillRectangle(brush,fade);
            }
            using (var pen = new Pen(Color.FromArgb(65,65,65)))
                e.Graphics.DrawLine(pen, 0, banner.Height-1, banner.Width-1, banner.Height-1);
            int padding = Math.Max(12, banner.Height/5);
            int textLeft = padding;
            if (unlock)
            {
                int size = Math.Max(16, Math.Min(32, banner.Height-padding*2));
                using (var stream = typeof(KeeTheme).Assembly.GetManifestResourceStream("KeeTheme.Resources.ModernWindow.ico"))
                {
                    if (stream != null)
                        using (var icon = new Icon(stream, size, size))
                            e.Graphics.DrawIcon(icon, new Rectangle(padding,(banner.Height-size)/2,size,size));
                }
                textLeft += size + padding;
            }
            using (var font = new Font(banner.Font.FontFamily, banner.Font.Size * 1.3f, FontStyle.Bold))
                TextRenderer.DrawText(e.Graphics, unlock ? KeePass.Resources.KPRes.EnterCompositeKey : group ? KeePass.Resources.KPRes.EditGroup : KeePass.Resources.KPRes.EditEntry,
                    font, new Rectangle(textLeft,padding,Math.Max(0,banner.Width-textLeft-padding),banner.Height-padding*2), _theme.Form.ForeColor,
                    TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis);
        }
        private void HandleModernCalendarDropDown(object sender, EventArgs e)
        {
            if (!UseModernIcons || MonoWorkarounds.IsRequired()) return;
            var picker = (DateTimePicker)sender;
            IntPtr calendar = ListViewNativeWindow.SendMessage(picker.Handle,0x1008,IntPtr.Zero,IntPtr.Zero);
            if (calendar == IntPtr.Zero) return;
            ApplyModernCalendarColors(calendar);
        }

        internal static void ApplyModernCalendarColors(IntPtr calendar)
        {
            if (calendar == IntPtr.Zero || MonoWorkarounds.IsRequired()) return;
            // Month calendars ignore most MCSC colors while visual styles are active.
            // Disable them on this transient popup only, not on the date picker.
            SetWindowTheme(calendar, "", "");
            int[] colors = { ColorTranslator.ToWin32(Color.FromArgb(37,37,38)), ColorTranslator.ToWin32(Color.FromArgb(241,241,241)),
                ColorTranslator.ToWin32(Color.FromArgb(45,45,48)), ColorTranslator.ToWin32(Color.FromArgb(241,241,241)),
                ColorTranslator.ToWin32(Color.FromArgb(37,37,38)), ColorTranslator.ToWin32(Color.FromArgb(190,190,190)) };
            // MCM_SETCOLOR updates the actual popup created for this opening.
            for (int i=0;i<colors.Length;i++) ListViewNativeWindow.SendMessage(calendar,0x100A,new IntPtr(i),new IntPtr(colors[i]));
        }

		private void OverrideScrollBarsSetExplorerTheme(Control control)
		{
			if (!CanHaveScrollBars(control) || MonoWorkarounds.IsRequired())
				return;

			var useExplorerDarkMode = _theme.ScrollBar.UseExplorerDarkMode;
			TrySetWindowTheme(control.Handle, _enabled && useExplorerDarkMode);

			control.HandleCreated -= HandleControlCreated;
			control.HandleCreated += HandleControlCreated;

			var keePassForm = control as Form;
			if (keePassForm != null && keePassForm.GetType().Namespace.StartsWith("KeePass"))
			{
				keePassForm.Load -= HandleKeePassFormLoad;
				keePassForm.Load += HandleKeePassFormLoad;
			}
		}

		private void HandleControlCreated(object sender, EventArgs e)
		{
			var createdControl = sender as Control;
			if (createdControl != null && createdControl.IsHandleCreated)
				TrySetWindowTheme(createdControl.Handle, _enabled && _theme.ScrollBar.UseExplorerDarkMode);
		}

		private void HandleKeePassFormLoad(object sender, EventArgs e)
		{
			var privateCustomListsField = sender.GetType()
				.GetFields(BindingFlags.Instance | BindingFlags.NonPublic);

			foreach (var fieldInfo in privateCustomListsField)
			{
				if (fieldInfo.FieldType == typeof(CustomListViewEx))
				{
					var customListView = fieldInfo.GetValue(sender) as CustomListViewEx;
					if (customListView != null && customListView.IsHandleCreated)
					{
						TrySetWindowTheme(customListView.Handle, _enabled && _theme.ScrollBar.UseExplorerDarkMode);
					}
				}
			}
		}

		private bool CanHaveScrollBars(Control control)
		{
			return control is TextBoxBase ||
			       control is ListBox ||
			       control is ListView ||
			       control is TreeView ||
			       control is DataGridView ||
			       control is Panel ||
			       control is UserControl ||
			       control is Form ||
			       control is ScrollableControl ||
			       control is TabControl;
		}

		private void OverrideResetBackground(Control control)
		{
			if (control.Name == "m_cmbStringName" && control.Parent.Name == "EditStringForm")
			{
				control.BackColorChanged += (sender, args) =>
				{
					if (control.BackColor.IsSystemColor)
						control.BackColor = _theme.Control.BackColor;
				};
			}

			if (control.Name == "m_tbSearch" && control.Parent.Name == "OptionsForm")
			{
				control.BackColorChanged += (sender, args) =>
				{
					if (control.BackColor.IsSystemColor)
						control.BackColor = _theme.Control.BackColor;
				};
			}
		}

		private void Apply(DataGridView dataGridView)
		{
			dataGridView.BackgroundColor = _theme.Control.BackColor;
			dataGridView.RowsDefaultCellStyle.BackColor = _theme.Control.BackColor;
			dataGridView.RowsDefaultCellStyle.ForeColor = _theme.Control.ForeColor;
		}

		private void Apply(CheckBox checkBox)
		{
			var checkBoxLook = checkBox.Appearance == Appearance.Button
				? _theme.CheckBoxButton
				: _theme.CheckBox;

			checkBox.BackColor = checkBoxLook.BackColor;
			checkBox.ForeColor = checkBoxLook.ForeColor;
			checkBox.FlatStyle = checkBoxLook.FlatStyle;
			checkBox.FlatAppearance.BorderColor = checkBoxLook.BorderColor;
			checkBox.FlatAppearance.CheckedBackColor = checkBoxLook.CheckedBackColor;
			checkBox.FlatAppearance.MouseDownBackColor = checkBoxLook.MouseDownBackColor;
			checkBox.FlatAppearance.MouseOverBackColor = checkBoxLook.MouseOverBackColor;

			checkBox.EnabledChanged -= HandleCheckBoxEnabledChanged;
			checkBox.EnabledChanged += HandleCheckBoxEnabledChanged;
            checkBox.Paint -= HandleModernCheckBoxPaint;
            if (UseModernIcons && checkBox.Appearance == Appearance.Normal)
                checkBox.Paint += HandleModernCheckBoxPaint;
		}

        private void HandleModernCheckBoxPaint(object sender, PaintEventArgs e)
        {
            if (!UseModernIcons) return;
            var box = (CheckBox)sender;
            Size glyph = CheckBoxRenderer.GetGlyphSize(e.Graphics,CheckBoxState.UncheckedNormal);
            bool right = box.CheckAlign == System.Drawing.ContentAlignment.TopRight || box.CheckAlign == System.Drawing.ContentAlignment.MiddleRight || box.CheckAlign == System.Drawing.ContentAlignment.BottomRight;
            bool center = box.CheckAlign == System.Drawing.ContentAlignment.TopCenter || box.CheckAlign == System.Drawing.ContentAlignment.MiddleCenter || box.CheckAlign == System.Drawing.ContentAlignment.BottomCenter;
            int x = right ? box.Width-glyph.Width : center ? (box.Width-glyph.Width)/2 : 0;
            int y = (box.Height-glyph.Height)/2;
            if (box.CheckAlign == System.Drawing.ContentAlignment.TopLeft || box.CheckAlign == System.Drawing.ContentAlignment.TopCenter || box.CheckAlign == System.Drawing.ContentAlignment.TopRight) y = 0;
            if (box.CheckAlign == System.Drawing.ContentAlignment.BottomLeft || box.CheckAlign == System.Drawing.ContentAlignment.BottomCenter || box.CheckAlign == System.Drawing.ContentAlignment.BottomRight) y = box.Height-glyph.Height;
            var r = new Rectangle(x,y,glyph.Width,glyph.Height);
            using (var brush = new SolidBrush(box.BackColor)) e.Graphics.FillRectangle(brush,r);
            using (var brush = new SolidBrush(box.Checked ? Color.FromArgb(56,101,138) : Color.FromArgb(37,37,38))) e.Graphics.FillRectangle(brush,r);
            using (var pen = new Pen(box.Enabled ? Color.FromArgb(110,110,110) : Color.FromArgb(65,65,65))) e.Graphics.DrawRectangle(pen,r.X,r.Y,r.Width-1,r.Height-1);
            if (box.CheckState == CheckState.Indeterminate)
                using (var brush = new SolidBrush(Color.FromArgb(190,190,190))) e.Graphics.FillRectangle(brush,r.X+3,r.Y+r.Height/2-1,r.Width-6,2);
            else if (box.Checked)
              {
                  var state = e.Graphics.Save();
                  e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
                using (var pen = new Pen(box.Enabled ? Color.FromArgb(241,241,241) : Color.FromArgb(190,190,190),1.7f))
                  {
                      pen.StartCap = pen.EndCap = System.Drawing.Drawing2D.LineCap.Round;
                      pen.LineJoin = System.Drawing.Drawing2D.LineJoin.Round;
                      e.Graphics.DrawLines(pen,new PointF[]{new PointF(r.X+r.Width*0.24f,r.Y+r.Height*0.51f),
                          new PointF(r.X+r.Width*0.43f,r.Y+r.Height*0.70f),new PointF(r.X+r.Width*0.77f,r.Y+r.Height*0.27f)});
                  }
                  e.Graphics.Restore(state);
              }
        }

		private void HandleCheckBoxEnabledChanged(object sender, EventArgs e)
		{
			var checkBox = (CheckBox) sender;
			if (checkBox.Enabled)
			{
				checkBox.Paint -= HandleCheckBoxPaint;
				checkBox.Invalidate();
			}
			else
			{
				checkBox.Paint += HandleCheckBoxPaint;
			}
		}

		private void HandleCheckBoxPaint(object sender, PaintEventArgs e)
		{
			var checkBox = (CheckBox) sender;
			var disabledForeColor = ControlPaint.Dark(_theme.Button.ForeColor, 0.25f);
			var glyphSize = CheckBoxRenderer.GetGlyphSize(e.Graphics, CheckBoxState.UncheckedNormal);
			var flags = TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.SingleLine;
			var clientRectangle = new Rectangle(glyphSize.Width, -1,
				checkBox.ClientRectangle.Size.Width - glyphSize.Width, checkBox.ClientRectangle.Size.Height);

			TextRenderer.DrawText(e.Graphics, checkBox.Text, checkBox.Font, clientRectangle, disabledForeColor, flags);
		}

		private void Apply(ComboBox comboBox)
		{
			if (comboBox.DropDownStyle == ComboBoxStyle.DropDownList)
				comboBox.FlatStyle = UseModernIcons ? FlatStyle.Flat : FlatStyle.Popup;

            comboBox.DrawItem -= HandleModernComboDrawItem;
            DrawMode original;
            if (UseModernIcons && comboBox.DropDownStyle == ComboBoxStyle.DropDownList &&
                (comboBox.DrawMode == DrawMode.Normal || _comboDrawModes.ContainsKey(comboBox)))
            {
                if (!_comboDrawModes.ContainsKey(comboBox))
                {
                    _comboDrawModes.Add(comboBox,comboBox.DrawMode);
                    comboBox.Disposed += delegate { _comboDrawModes.Remove(comboBox); };
                }
                comboBox.DrawMode = DrawMode.OwnerDrawFixed;
                comboBox.DrawItem += HandleModernComboDrawItem;
            }
            else if (_comboDrawModes.TryGetValue(comboBox,out original))
            {
                comboBox.DrawMode=original;
                _comboDrawModes.Remove(comboBox);
            }

			comboBox.BackColorChanged -= HandleComboBoxBackColorChanged;
			comboBox.BackColorChanged += HandleComboBoxBackColorChanged;
		}

        private void HandleModernComboDrawItem(object sender,DrawItemEventArgs e)
        {
            var combo=(ComboBox)sender;
            bool display=(e.State & DrawItemState.ComboBoxEdit)!=0;
            bool selected=!display && (e.State & DrawItemState.Selected)!=0;
            Color background=selected ? Color.FromArgb(56,101,138) : combo.BackColor;
            using(var brush=new SolidBrush(background))e.Graphics.FillRectangle(brush,e.Bounds);
            string text=e.Index>=0 && e.Index<combo.Items.Count ? combo.GetItemText(combo.Items[e.Index]) : combo.Text;
            var bounds=e.Bounds; bounds.Inflate(-3,0);
            TextRenderer.DrawText(e.Graphics,text,combo.Font,bounds,combo.Enabled ? Color.FromArgb(241,241,241) : Color.FromArgb(190,190,190),
                TextFormatFlags.Left|TextFormatFlags.VerticalCenter|TextFormatFlags.SingleLine|TextFormatFlags.EndEllipsis|TextFormatFlags.NoPrefix);
        }

		private void HandleComboBoxBackColorChanged(object sender, EventArgs e)
		{
			if (!_enabled)
			{
				return;
			}

			var comboBox = (ComboBox) sender;
			if (comboBox.BackColor == SystemColors.Window)
				comboBox.BackColor = _theme.Control.BackColor;
		}

		private void Apply(QualityProgressBar qualityProgressBar)
		{
			qualityProgressBar.ForeColor = _theme.Form.BackColor;
		}

		private void Apply(TabControl tabControl)
		{
			var decoratorName = tabControl.Name + "_decorator";
			var decorator =
				tabControl.Parent.Controls.Find(decoratorName, false).FirstOrDefault() as TabControlDecorator;

			if (decorator == null)
			{
				decorator = new TabControlDecorator(tabControl, _theme);
				decorator.Name = decoratorName;
			}

			tabControl.BackColor = _theme.TabControl.BackColor;
			tabControl.ForeColor = _theme.TabControl.ForeColor;

			decorator.EnableTheme(_enabled, _theme);

			tabControl.ControlAdded -= HandleTabControlAdded;
			tabControl.ControlAdded += HandleTabControlAdded;
		}

		private void Apply(TabPage tabPage)
		{
			tabPage.Invalidated -= HandleTabPageInvalidated;
			tabPage.Invalidated += HandleTabPageInvalidated;
		}

		private void HandleTabPageInvalidated(object sender, InvalidateEventArgs e)
		{
			var tabPage = (TabPage) sender;
			if (tabPage.UseVisualStyleBackColor)
			{
				tabPage.UseVisualStyleBackColor = false;
			}
		}

		private void HandleTabControlAdded(object sender, ControlEventArgs e)
		{
			if (e.Control is TabPage)
			{
				var visitor = new ControlVisitor(Apply);
				visitor.Visit(e.Control);
			}
		}

		private void Apply(StatusStrip statusStrip)
		{
			statusStrip.BackColor = _theme.MenuItem.BackColor;
			statusStrip.ForeColor = _theme.MenuItem.ForeColor;

			Apply(statusStrip.Items);
		}

		private void Apply(ContextMenuStrip contextMenuStrip)
		{
			contextMenuStrip.BackColor = _theme.MenuItem.BackColor;
			contextMenuStrip.ForeColor = _theme.MenuItem.ForeColor;

			Apply(contextMenuStrip.Items);
		}

		private void Apply(MenuStrip menuStrip)
		{
			menuStrip.BackColor = _theme.MenuItem.BackColor;
			menuStrip.ForeColor = _theme.MenuItem.ForeColor;

			Apply(menuStrip.Items);
		}

		private void Apply(ToolStrip toolStrip)
		{
			toolStrip.BackColor = _theme.MenuItem.BackColor;
			toolStrip.ForeColor = _theme.MenuItem.ForeColor;

			            CenteredSearchDecorator centered;
            if (_centeredSearch.TryGetValue(toolStrip, out centered))
            { centered.Dispose(); _centeredSearch.Remove(toolStrip); }
            Apply(toolStrip.Items);
            var search = toolStrip.Items.OfType<ToolStripComboBox>().FirstOrDefault(x =>
                x.Name == "m_tbQuickFind" || x.Name == "m_tbQuickSearch");
            if (_enabled && _theme.MenuItem.ModernIcons && search != null &&
                toolStrip.FindForm() != null && toolStrip.FindForm().GetType().FullName == "KeePass.Forms.MainForm")
                {
                _centeredSearch.Add(toolStrip,new CenteredSearchDecorator(toolStrip, search));
                toolStrip.Disposed -= HandleCenteredStripDisposed;
                toolStrip.Disposed += HandleCenteredStripDisposed;
            }
		}

		private void HandleCenteredStripDisposed(object sender, EventArgs e)
        { _centeredSearch.Remove((ToolStrip)sender); }

        private void Apply(ToolStripItemCollection toolStripItemCollection)
		{
			foreach (ToolStripItem item in toolStripItemCollection)
			{
				                var owner = item.Owner;
                var mainForm = owner == null ? null : owner.FindForm();
                bool modernToolbar = _enabled && _theme.MenuItem.ModernIcons &&
                    owner != null && !(owner is ToolStripDropDown) && !(owner is MenuStrip) &&
                    !(owner is StatusStrip) && mainForm != null &&
                    mainForm.GetType().FullName == "KeePass.Forms.MainForm";
                                bool knownToolbarItem = item.Name.StartsWith("m_tb") &&
                    (item is ToolStripButton || item is ToolStripSplitButton ||
                     item is ToolStripDropDownButton || item is ToolStripSeparator);
                if (knownToolbarItem)
                {
                    bool available;
                    if (modernToolbar)
                    {
                        if (!_toolbarAvailable.TryGetValue(item, out available))
                        {
                            available = item.Available;
                            _toolbarAvailable.Add(item, available);
                            item.Disposed -= HandleToolbarItemDisposed;
                            item.Disposed += HandleToolbarItemDisposed;
                        }
                        item.Available = available;
                    }
                    else if (_toolbarAvailable.TryGetValue(item, out available))
                    {
                        item.Available = available;
                        _toolbarAvailable.Remove(item);
                    }
                }
                if (item is ToolStripComboBox && (item.Name == "m_tbQuickFind" || item.Name == "m_tbQuickSearch"))
                {
                    if (modernToolbar)
                    {
                        if (!_searchSize.ContainsKey(item))
                        {
                            _searchSize.Add(item,item.Size);
                            _searchAutoSize.Add(item,item.AutoSize);
                            item.Disposed -= HandleToolbarItemDisposed;
                            item.Disposed += HandleToolbarItemDisposed;
                        }
                        item.AutoSize = false;
                        item.Width = System.Math.Max(_searchSize[item].Width,owner.ImageScalingSize.Width * 20);
                    }
                    else if (_searchSize.ContainsKey(item))
                    {
                        item.AutoSize = _searchAutoSize[item];
                        item.Size = _searchSize[item];
                        _searchSize.Remove(item); _searchAutoSize.Remove(item);
                    }
                }
                if (item is ToolStripButton || item is ToolStripSplitButton || item is ToolStripDropDownButton)
                {
                    Padding original;
                    if (modernToolbar)
                    {
                        if (!_toolbarPadding.TryGetValue(item, out original))
                        {
                            original = item.Padding;
                            _toolbarPadding.Add(item, original);
                            item.Disposed += HandleToolbarItemDisposed;
                        }
                        int inset = System.Math.Max(2, owner.ImageScalingSize.Width / 8);
                        item.Padding = new Padding(original.Left + inset, original.Top + 2,
                            original.Right + inset, original.Bottom + 2);
                    }
                    else if (_toolbarPadding.TryGetValue(item, out original))
                    {
                        item.Padding = original;
                        _toolbarPadding.Remove(item);
                        item.Disposed -= HandleToolbarItemDisposed;
                    }
                }
                item.ForeColor = _theme.MenuItem.ForeColor;
				item.BackColor = _theme.MenuItem.BackColor;

				var menuItem = item as ToolStripMenuItem;
				if (menuItem != null)
				{
					menuItem.DropDownOpening -= HandleMenuItemOnDropDownOpening;
					menuItem.DropDownOpening += HandleMenuItemOnDropDownOpening;
				}
			}
		}

		private void HandleToolbarItemDisposed(object sender, EventArgs e)
        {
            var item=(ToolStripItem)sender;
            _toolbarPadding.Remove(item); _toolbarAvailable.Remove(item);
            _searchSize.Remove(item); _searchAutoSize.Remove(item);
        }

        private void HandleMenuItemOnDropDownOpening(object sender, EventArgs e)
		{
			var menuItem = (ToolStripMenuItem) sender;
			Apply(menuItem.DropDownItems);
		}

		private void Apply(SecureTextBoxEx secureTextBoxEx)
		{
			secureTextBoxEx.BackColorChanged -= HandleSecureTextBoxExOnBackColorChanged;
			secureTextBoxEx.BackColorChanged += HandleSecureTextBoxExOnBackColorChanged;
		}

		private void HandleSecureTextBoxExOnBackColorChanged(object sender, EventArgs e)
		{
			if (!_enabled)
			{
				return;
			}

			var textBox = (SecureTextBoxEx) sender;
			if (textBox.BackColor == SystemColors.Window)
				textBox.BackColor = _theme.SecureTextBox.BackColor;
		}

		private void Apply(HotKeyControlEx hotKeyControlEx)
		{
			hotKeyControlEx.BackColorChanged -= HandleHotKeyControlExOnBackColorChanged;
			hotKeyControlEx.BackColorChanged += HandleHotKeyControlExOnBackColorChanged;
		}

		private void HandleHotKeyControlExOnBackColorChanged(object sender, EventArgs e)
		{
			if (!_enabled)
			{
				return;
			}

			var textBox = (HotKeyControlEx) sender;
			if (textBox.BackColor == SystemColors.Window)
				textBox.BackColor = _theme.Control.BackColor;
		}

		private void Apply(Form form)
		{
			form.BackColor = _theme.Form.BackColor;
			form.ForeColor = _theme.Form.ForeColor;

			foreach (var component in GetComponents(form))
			{
				Apply(component);
			}
		}

		private void Apply(UserControl userControl)
		{
			userControl.BackColor = _theme.Form.BackColor;
			userControl.ForeColor = _theme.Form.ForeColor;

			foreach (var component in GetComponents(userControl))
			{
				Apply(component);
			}
		}

		private IEnumerable<Control> GetComponents(ContainerControl containerControl)
		{
			var componentsField = containerControl.GetType()
				.GetField("components", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);

			if (componentsField != null)
			{
				var components = componentsField.GetValue(containerControl) as IContainer;
				if (components != null)
				{
					return components.Components.OfType<Control>();
				}
			}

			return Enumerable.Empty<Control>();
		}

		private void Apply(Button button)
		{
			button.Paint -= HandleModernEntryButtonPaint;
			var entryForm = button.FindForm();
			if (UseModernIcons && entryForm != null && (entryForm.GetType().FullName == "KeePass.Forms.PwEntryForm" || entryForm.GetType().FullName == "KeePass.Forms.GroupForm") &&
				(button.Name == "m_btnIcon" || button.Name == "m_btnGenPw" || button.Name == "m_btnStandardExpires"))
				button.Paint += HandleModernEntryButtonPaint;
            if (UseModernIcons && entryForm != null && entryForm.GetType().FullName == "KeePass.Forms.KeyPromptForm" && button.Name == "m_btnOpenKeyFile")
                button.Paint += HandleModernEntryButtonPaint;
			button.BackColor = _theme.Button.BackColor;
			button.ForeColor = _theme.Button.ForeColor;
			button.FlatAppearance.BorderColor = _theme.Button.BorderColor;
			button.FlatStyle = _theme.Button.FlatStyle;

			if (button is SplitButtonEx)
			{
				var decorator = button.Controls.OfType<SplitButtonExDecorator>().FirstOrDefault()
				                ?? new SplitButtonExDecorator((SplitButtonEx) button, _theme);

				decorator.EnableTheme(_enabled, _theme);
			}

			button.EnabledChanged -= HandleButtonEnabledChanged;
			button.EnabledChanged += HandleButtonEnabledChanged;
		}

		private void HandleModernEntryButtonPaint(object sender, PaintEventArgs e)
		{
			var button = (Button)sender;
			var form = button.FindForm();
			if (!UseModernIcons || form == null || button.Image == null) return;
			int icon = 0;
			if (button.Name == "m_btnIcon")
			{
				var flags = System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic;
				var customField = form.GetType().GetField("m_pwCustomIconID", flags);
				var iconField = form.GetType().GetField(form.GetType().FullName == "KeePass.Forms.GroupForm" ? "m_pwIconIndex" : "m_pwEntryIcon", flags);
				if (customField == null || iconField == null) return;
				var custom = customField.GetValue(form) as PwUuid;
				if (custom == null || !custom.Equals(PwUuid.Zero)) return;
				icon = (int)(PwIcon)iconField.GetValue(form);
				if (icon < 0 || icon >= (int)PwIcon.Count) return;
			}
			// Draw over the original button image without replacing or disposing KeePass images.
			var image = button.Image;
			var bounds = new Rectangle((button.ClientSize.Width - image.Width) / 2,
				(button.ClientSize.Height - image.Height) / 2, image.Width, image.Height);
			using (var brush = new SolidBrush(button.BackColor)) e.Graphics.FillRectangle(brush, bounds);
			var color = button.Enabled ? button.ForeColor : Color.FromArgb(190,190,190);
			if (button.Name == "m_btnOpenKeyFile")
                ModernToolbarIcons.Draw(e.Graphics, bounds, "m_tbOpenDatabase", color);
            else if (button.Name == "m_btnStandardExpires")
				ModernToolbarIcons.Draw(e.Graphics, bounds, "m_tbViewsShowExpired", color);
			else ModernStandardIcons.Draw(e.Graphics, bounds, icon, color);
		}

		private void HandleButtonEnabledChanged(object sender, EventArgs e)
		{
			var button = (Button) sender;
			if (button.Enabled)
			{
				button.Paint -= HandleButtonPaint;
			}
			else
			{
				button.Paint += HandleButtonPaint;
			}
		}

		private void HandleButtonPaint(object sender, PaintEventArgs e)
		{
			var button = (Button) sender;
			var disabledForeColor = ControlPaint.Dark(_theme.Button.ForeColor, 0.25f);
			if (button.Enabled)
			{
				disabledForeColor = _theme.Button.ForeColor;
			}

			var flags = TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.WordBreak;
			TextRenderer.DrawText(e.Graphics, button.Text, button.Font, button.ClientRectangle, disabledForeColor,
				flags);
		}

		private void Apply(LinkLabel linkLabel)
		{
			linkLabel.LinkColor = _theme.LinkLabel.LinkColor;
		}

		private void Apply(TreeView treeView)
		{
			treeView.BorderStyle = _theme.TreeView.BorderStyle;
			treeView.BackColor = _theme.TreeView.BackColor;

			if (!MonoWorkarounds.IsRequired())
			{
				treeView.DrawMode = _enabled && _theme.MenuItem.ModernIcons && treeView.Name == "m_tvGroups"
                    ? TreeViewDrawMode.OwnerDrawAll : _theme.TreeViewDrawMode;
				treeView.DrawNode -= HandleTreeViewDrawNode;
				treeView.DrawNode += HandleTreeViewDrawNode;
			}
		}

		[DllImport("UxTheme.dll", ExactSpelling = true, CharSet = CharSet.Unicode)]
		private static extern int SetWindowTheme(IntPtr hWnd, string pszSubAppName, string pszSubIdList);

		public static void TrySetWindowTheme(IntPtr hWnd, bool enable)
		{
			if (hWnd == IntPtr.Zero || MonoWorkarounds.IsRequired())
				return;

			try
			{
				SetWindowTheme(hWnd, enable ? "DarkMode_Explorer" : "explorer", null);
			}
			catch (Exception)
			{
				// ignored
			}
		}

		private void HandleTreeViewDrawNode(object sender, DrawTreeNodeEventArgs e)
		{
			// DrawDefault = true does not have TextFormatFlags.NoPrefix flag set
			var node = e.Node;
            if (node.TreeView.DrawMode == TreeViewDrawMode.OwnerDrawAll && DrawModernGroup(e)) return;

			var isNodeSelected = (e.State & TreeNodeStates.Selected) == TreeNodeStates.Selected;
			var foreColor = isNodeSelected && node.TreeView.Focused
				? _theme.TreeView.SelectionColor
				: _theme.TreeView.ForeColor != Color.Empty
					? _theme.TreeView.ForeColor
					: node.TreeView.ForeColor;

			var backColor = isNodeSelected ? _theme.TreeView.SelectionBackColor : _theme.TreeView.BackColor;

			var font = node.NodeFont ?? node.TreeView.Font;
			var size = TextRenderer.MeasureText(node.Text, font, e.Bounds.Size, TextFormatFlags.NoPrefix);
			var rectangle = new Rectangle(new Point(node.Bounds.X - 1, node.Bounds.Y),
				new Size(size.Width, node.Bounds.Height));

			using (var backColorBrush = new SolidBrush(backColor))
				e.Graphics.FillRectangle(backColorBrush, rectangle);

			if (isNodeSelected && node.TreeView.Focused)
				ControlPaint.DrawFocusRectangle(e.Graphics, rectangle, foreColor, backColor);

			TextRenderer.DrawText(e.Graphics, node.Text, font, rectangle, foreColor, TextFormatFlags.NoPrefix);
		}

		        private bool DrawModernGroup(DrawTreeNodeEventArgs e)
        {
            var node = e.Node;
            var group = node.Tag as PwGroup;
            if (group == null) { e.DrawDefault = true; return true; }
            var tree = node.TreeView;
            var textBounds = node.Bounds;
            bool selected = (e.State & TreeNodeStates.Selected) != 0;
            var back = selected ? _theme.TreeView.SelectionBackColor : _theme.TreeView.BackColor;
            var fore = selected ? _theme.TreeView.SelectionColor : _theme.TreeView.ForeColor;
            using (var brush = new SolidBrush(back))
                e.Graphics.FillRectangle(brush, new Rectangle(0,textBounds.Y,tree.ClientSize.Width,textBounds.Height));
            var images = tree.ImageList;
            int imageWidth = images == null ? 0 : images.ImageSize.Width;
            int imageHeight = images == null ? 0 : images.ImageSize.Height;
            var iconBounds = new Rectangle(textBounds.X-imageWidth-3,
                textBounds.Y+(textBounds.Height-imageHeight)/2,imageWidth,imageHeight);
            if (images != null)
            {
                string key = selected ? node.SelectedImageKey : node.ImageKey;
                int index = selected ? node.SelectedImageIndex : node.ImageIndex;
                if (!string.IsNullOrEmpty(key)) index = images.Images.IndexOfKey(key);
                if (index < 0) index = selected ? tree.SelectedImageIndex : tree.ImageIndex;
                if (index >= 0 && index < images.Images.Count &&
                    (!group.CustomIconUuid.Equals(PwUuid.Zero) || index >= (int)PwIcon.Count ||
                     !ModernStandardIcons.Draw(e.Graphics,iconBounds,index,fore)))
                    images.Draw(e.Graphics,iconBounds.Location,index);
            }
            if (tree.ShowPlusMinus && node.Nodes.Count > 0)
            {
                float x = iconBounds.Left-tree.Indent/2f;
                float y = textBounds.Y+textBounds.Height/2f;
                float d = System.Math.Max(3f,imageWidth/5f);
                var state=e.Graphics.Save();
                try
                {
                    e.Graphics.SmoothingMode=System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
                    using(var pen=new Pen(fore,1.4f))
                    {
                        if(node.IsExpanded) e.Graphics.DrawLines(pen,new PointF[]{new PointF(x-d,y-d/2),new PointF(x,y+d/2),new PointF(x+d,y-d/2)});
                        else e.Graphics.DrawLines(pen,new PointF[]{new PointF(x-d/2,y-d),new PointF(x+d/2,y),new PointF(x-d/2,y+d)});
                    }
                }
                finally {e.Graphics.Restore(state);}
            }
            TextRenderer.DrawText(e.Graphics,node.Text,node.NodeFont ?? tree.Font,textBounds,fore,
                TextFormatFlags.NoPrefix | TextFormatFlags.VerticalCenter);
            if(selected && tree.Focused) ControlPaint.DrawFocusRectangle(e.Graphics,textBounds,fore,back);
            return true;
        }
        private void Apply(RichTextBox richTextBox)
		{
			var decorator = richTextBox.Parent as RichTextBoxDecorator;
			if (decorator == null)
			{
				decorator = new RichTextBoxDecorator(richTextBox, _theme);
			}

			decorator.EnableTheme(_enabled, _theme);
		}

		private void Apply(ListView listView)
		{
			            var form = listView.FindForm();
            if (listView.Name == "m_lvIcons" && form != null && form.GetType().FullName == "KeePass.Forms.IconPickerForm")
            {
                var picker = listView.Controls.OfType<StandardIconPickerDecorator>().FirstOrDefault()
                    ?? new StandardIconPickerDecorator(listView);
                picker.Apply(_enabled, _theme);
            }
            if (ObjectListViewDecorator.CanDecorate(listView))
			{
				ObjectListViewDecorator.Apply(listView, _theme);
				return;
			}

			var decorator = listView.Controls.OfType<ListViewDecorator>().FirstOrDefault()
			                ?? new ListViewDecorator(listView, _theme);

			decorator.EnableTheme(_enabled, _theme);
		}

		private void Apply(PropertyGrid propertyGrid)
		{
			propertyGrid.CategoryForeColor = _theme.PropertyGrid.CategoryForeColor;
			propertyGrid.LineColor = _theme.PropertyGrid.LineColor;
		}
	}
}
