using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Core.Messaging;

public interface IQuery : IRequest<Result> { }
public interface IQuery<TResponse> : IRequest<Result<TResponse>> { }
