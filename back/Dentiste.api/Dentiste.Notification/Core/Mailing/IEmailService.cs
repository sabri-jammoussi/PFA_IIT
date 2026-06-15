using System.Threading.Tasks;

namespace Dentiste.Notification.Core.Mailing
{
    public interface IEmailService
    {
        Task Send(AppEmail email);
    }
}
