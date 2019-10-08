namespace NazgHeredityTest\Middleware;

use type Facebook\Experimental\Http\Message\{
  ResponseInterface,
  ServerRequestInterface,
};
use type Nazg\Http\Server\{AsyncMiddlewareInterface, AsyncRequestHandlerInterface};
use type HH\Lib\Experimental\IO\WriteHandle;

final class AsyncMockMiddleware implements AsyncMiddlewareInterface {

  const string MOCK_HEADER = 'x-testing-call-count';

  public async function processAsync(
    WriteHandle $writeHandle,
    ServerRequestInterface $request,
    AsyncRequestHandlerInterface $handler,
  ): Awaitable<ResponseInterface> {
    $request = $request->withAddedHeader(self::MOCK_HEADER, vec["1"]);
    return await $handler->handleAsync($writeHandle, $request);
  }
}
