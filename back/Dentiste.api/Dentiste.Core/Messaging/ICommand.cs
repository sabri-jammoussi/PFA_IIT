using MediatR;
using Dentiste.Core.Shared;

namespace Dentiste.Core.Messaging;

public interface ICommand : IRequest<Result>, IBaseCommand { }
public interface ICommand<TResponse> : IRequest<Result<TResponse>>, IBaseCommand { }
public interface IBaseCommand { }
