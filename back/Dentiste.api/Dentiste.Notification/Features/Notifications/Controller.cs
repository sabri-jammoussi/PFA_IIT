using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Dentiste.Notification.Features.Notifications.Commands.MarkAsSeen;
using Dentiste.Notification.Features.Notifications.Commands.MarkAsSeenById;
using Dentiste.Notification.Features.Notifications.Queries;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.Notifications
{
    [Authorize]
    [ApiController]
    [Route("api/nf/notifications")]
    public class Controller : ControllerBase
    {
        private readonly ISender _sender;

        public Controller(ISender sender)
        {
            _sender = sender;
        }

        [HttpGet("count")]
        public async Task<IActionResult> GetCount()
        {
            var query = new GetCountNotificationsQuery();
            var result = await _sender.Send(query);
            if (result.IsSuccess)
            {
                return Ok(result);
            }
            return BadRequest(result.Error);
        }

        [HttpGet]
        public async Task<IActionResult> GetNotifications()
        {
            var query = new GetNotificationsQuery();
            var result = await _sender.Send(query);
            if (result.IsSuccess)
            {
                return Ok(result);
            }
            return BadRequest(result.Error);
        }

        [HttpPost("seen")]
        public async Task<IActionResult> MarkAllAsSeen()
        {
            var command = new MarkAsSeenCommand();
            var result = await _sender.Send(command);
            if (result.IsSuccess)
            {
                return Ok(result);
            }
            return BadRequest(result.Error);
        }

        [HttpPost("seen/{id:int}")]
        public async Task<IActionResult> MarkAsSeenById(int id)
        {
            var command = new MarkAsSeenByIdCommand { Id = id };
            var result = await _sender.Send(command);
            if (result.IsSuccess)
            {
                return Ok(result);
            }
            return BadRequest(result.Error);
        }
    }
}
