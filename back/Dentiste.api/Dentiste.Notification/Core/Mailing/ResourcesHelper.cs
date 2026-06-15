using System.IO;
using System.Reflection;
using System.Threading.Tasks;

namespace Dentiste.Notification.Core.Mailing
{
    public class ResourcesHelper
    {
        private static readonly Assembly? _assembly;
        private static readonly string _assemblyName;

        static ResourcesHelper()
        {
            _assembly = Assembly.GetExecutingAssembly();
            _assemblyName = _assembly?.GetName().Name ?? string.Empty;
        }

        public static async Task<string?> ReadTextFile(string resourceName)
        {
            if (_assembly == null || string.IsNullOrEmpty(_assemblyName)) return null;
            
            // Format paths to match C# embedded resource naming conventions: Namespace.Folder.Subfolder.FileName
            var resourcePath = $"{_assemblyName}.{resourceName.Replace("\\", ".").Replace("/", ".")}";
            using var stream = _assembly.GetManifestResourceStream(resourcePath);
            if (stream == null) return null;
            
            using var reader = new StreamReader(stream);
            var result = await reader.ReadToEndAsync();
            return result;
        }
    }
}
