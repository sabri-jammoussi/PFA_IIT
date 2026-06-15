using DotLiquid;
using System.Threading.Tasks;

namespace Dentiste.Notification.Core.Mailing
{
    public class EmailRenderSubject : IEmailRenderSubject
    {
        public Task<string> RenderSubject(string userSubject, object subjectData)
        {
            var parsedTemplate = Template.Parse(userSubject);
            var rendered = parsedTemplate.Render(Hash.FromAnonymousObject(subjectData));
            return Task.FromResult(rendered);
        }
    }
}
