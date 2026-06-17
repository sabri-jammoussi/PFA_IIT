using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using FluentValidation;
using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Core.Infrastructure.Behaviors;

/// <summary>
/// MediatR pipeline behavior that runs all registered FluentValidation validators for the
/// incoming request. On failure it short-circuits the pipeline and returns a failed
/// <see cref="Result"/> (or <c>Result&lt;T&gt;</c>) instead of letting invalid data reach the handler.
/// </summary>
public class ValidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
    where TResponse : Result
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public ValidationBehavior(IEnumerable<IValidator<TRequest>> validators)
    {
        _validators = validators;
    }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        if (_validators.Any())
        {
            var context = new ValidationContext<TRequest>(request);
            var results = await Task.WhenAll(_validators.Select(v => v.ValidateAsync(context, cancellationToken)));
            var failures = results
                .SelectMany(r => r.Errors)
                .Where(f => f is not null)
                .ToList();

            if (failures.Count != 0)
            {
                var error = string.Join(" ", failures.Select(f => f.ErrorMessage).Distinct());
                return CreateFailure(error);
            }
        }

        return await next(cancellationToken);
    }

    private static TResponse CreateFailure(string error)
    {
        if (typeof(TResponse).IsGenericType && typeof(TResponse).GetGenericTypeDefinition() == typeof(Result<>))
        {
            var valueType = typeof(TResponse).GetGenericArguments()[0];
            var method = typeof(Result).GetMethods()
                .First(m => m.Name == nameof(Result.Failure) && m.IsGenericMethod)
                .MakeGenericMethod(valueType);
            return (TResponse)method.Invoke(null, new object[] { error })!;
        }

        return (TResponse)Result.Failure(error);
    }
}
