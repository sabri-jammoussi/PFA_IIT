using System.Threading.Tasks;

namespace Dentiste.Notification.Core.Mailing
{
    public interface ITemplateRender
    {
        Task<string> Render(string resourceName, object data);
    }
}
