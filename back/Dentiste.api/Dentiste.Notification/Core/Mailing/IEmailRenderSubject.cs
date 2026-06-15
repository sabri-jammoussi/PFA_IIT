using System.Threading.Tasks;

namespace Dentiste.Notification.Core.Mailing
{
    public interface IEmailRenderSubject
    {
        Task<string> RenderSubject(string userSubject, object subjectData);
    }
}
