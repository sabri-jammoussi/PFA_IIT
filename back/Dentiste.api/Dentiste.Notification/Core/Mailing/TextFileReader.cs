using System.Threading.Tasks;

namespace Dentiste.Notification.Core.Mailing
{
    public class TextFileReader : ITextFileReader
    {
        public async Task<string?> Read(string name)
        {
            var text = await ResourcesHelper.ReadTextFile(name);
            return text;
        }
    }
}
