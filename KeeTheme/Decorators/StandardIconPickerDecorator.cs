using System.Drawing;
using System.Windows.Forms;
using KeeTheme.Theme;

namespace KeeTheme.Decorators
{
    // Owns only the standard picker list's private preview images.
    internal sealed class StandardIconPickerDecorator : Control
    {
        private readonly ListView _list;
        private readonly Form _form;
        private ImageList _original;
        private ImageList _preview;
        private ITheme _theme;
        private bool _enabled;

        internal StandardIconPickerDecorator(ListView list)
        {
            _list = list;
            _form = list.FindForm();
            list.Controls.Add(this);
            if (_form != null) _form.Load += OnFormLoad;
        }
        private void OnFormLoad(object sender, System.EventArgs e) { Apply(_enabled, _theme); }
        internal void Apply(bool enabled, ITheme theme)
        {
            _enabled = enabled; _theme = theme;
            if (_list.SmallImageList != _preview) _original = _list.SmallImageList;
            if (_preview != null)
            {
                _list.SmallImageList = _original;
                _preview.Dispose(); _preview = null;
            }
            if (!enabled || theme == null || !theme.MenuItem.ModernIcons || _original == null) return;
            _preview = new ImageList();
            _preview.ImageSize = _original.ImageSize;
            _preview.ColorDepth = ColorDepth.Depth32Bit;
            // Force native storage before disposing each temporary drawing bitmap.
            var handle = _preview.Handle;
            for (int i = 0; i < _original.Images.Count; i++)
            {
                using (var bitmap = new Bitmap(_original.ImageSize.Width, _original.ImageSize.Height))
                using (var g = Graphics.FromImage(bitmap))
                {
                    if (!ModernStandardIcons.Draw(g, new Rectangle(Point.Empty,bitmap.Size), i, theme.ListView.ForeColor))
                        _original.Draw(g, Point.Empty, i);
                    _preview.Images.Add(_original.Images.Keys[i], bitmap);
                }
            }
            _list.SmallImageList = _preview;
            _list.Invalidate();
        }
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (_form != null) _form.Load -= OnFormLoad;
                if (_preview != null)
                {
                    if (!_list.IsDisposed && _list.SmallImageList == _preview) _list.SmallImageList = _original;
                    _preview.Dispose(); _preview = null;
                }
            }
            base.Dispose(disposing);
        }
    }
}
