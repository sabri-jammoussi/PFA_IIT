using System.Threading.Tasks;

namespace Dentiste.Notification.Core.Mailing
{
    public interface ITextFileReader
    {
        Task<string?> Read(string name);
    }
}
