using System.ComponentModel;
using System.Drawing;
using KeeTheme.Editor;

namespace KeeTheme.Theme
{
	[TypeConverter(typeof(MenuLookTypeConverter))]
	class MenuLook : ControlLook
	{
		public Color HighlightColor { get; set; }
        public Color DisabledForeColor { get; set; }
        public bool ModernIcons { get; set; }
	}
}
