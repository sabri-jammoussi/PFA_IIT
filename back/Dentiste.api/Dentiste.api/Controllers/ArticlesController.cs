using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Dentiste.Data;
using Dentiste.Core.Features.Articles;
using Dentiste.Core.Features.Articles.Commands.Add;
using Dentiste.Core.Features.Articles.Commands.Update;
using Dentiste.Core.Features.Articles.Commands.Delete;
using Dentiste.Core.Features.Articles.Commands.Restock;
using Dentiste.Core.Features.Articles.Queries.GetById;
using Dentiste.Core.Features.Articles.Queries.GetAll;
using Dentiste.Core.Features.Articles.Queries.GetLowStock;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/articles")]
[Authorize(Roles = $"{nameof(UserRole.Dentiste)},{nameof(UserRole.Secretaire)}")]
public class ArticlesController : ControllerBase
{
    private readonly ISender _sender;

    public ArticlesController(ISender sender)
    {
        _sender = sender;
    }

    [HttpGet]
    [Authorize(Roles = $"{nameof(UserRole.Secretaire)},{nameof(UserRole.Dentiste)}")]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 50, [FromQuery] string? search = null, [FromQuery] bool? lowStockOnly = null)
    {
        var query = new GetAllArticlesQuery
        {
            Page = page,
            PageSize = pageSize,
            SearchTerm = search,
            LowStockOnly = lowStockOnly
        };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpGet("{id:int}")]
    [Authorize(Roles = $"{nameof(UserRole.Secretaire)},{nameof(UserRole.Dentiste)}")]
    public async Task<IActionResult> GetById(int id)
    {
        var query = new GetArticleByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }

    [HttpGet("low-stock")]
    public async Task<IActionResult> GetLowStock()
    {
        var query = new GetLowStockArticlesQuery();
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddArticleCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value }, result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateArticleCommand command)
    {
        if (id != command.Id)
        {
            return BadRequest("L'ID spécifié dans l'URL ne correspond pas à celui du corps de la requête.");
        }

        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var command = new DeleteArticleCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }

    [HttpPatch("{id:int}/restock")]
    public async Task<IActionResult> Restock(int id, [FromBody] RestockArticleCommand command)
    {
        if (id != command.Id)
        {
            return BadRequest("L'ID spécifié dans l'URL ne correspond pas à celui du corps de la requête.");
        }

        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
