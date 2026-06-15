using DotLiquid;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;

namespace Dentiste.Notification.Core.Mailing
{
    public class LiquidTemplateRender : ITemplateRender
    {
        private readonly ILogger<LiquidTemplateRender> _logger;
        private readonly ITextFileReader _templateReader;

        public LiquidTemplateRender(
            ILogger<LiquidTemplateRender> logger,
            ITextFileReader templateReader)
        {
            _logger = logger;
            _templateReader = templateReader;
        }

        public async Task<string> Render(string resourceName, object data)
        {
            try
            {
                var templateText = await _templateReader.Read(resourceName);
                if (templateText == null)
                {
                    _logger.LogWarning("Template not found: {ResourceName}", resourceName);
                    return string.Empty;
                }

                var template = Template.Parse(templateText);
                var result = template.Render(Hash.FromAnonymousObject(data));
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while rendering template {ResourceName}", resourceName);
                return string.Empty;
            }
        }
    }
}
