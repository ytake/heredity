use type Nazg\Http\Server\AsyncRequestHandlerInterface;
use type Facebook\Experimental\Http\Message\{
  ResponseInterface,
  ServerRequestInterface,
};
use type Ytake\Hungrr\{Response, StatusCode};
use type NazgHeredityTest\Middleware\AsyncMockMiddleware;
use namespace HH\Lib\Experimental\IO;
use function json_encode;

final class AsyncSimpleRequestHandler implements AsyncRequestHandlerInterface {

  public async function handleAsync(
    IO\WriteHandle $handle,
    ServerRequestInterface $request
  ): Awaitable<ResponseInterface> {
    $header = $request->getHeader(AsyncMockMiddleware::MOCK_HEADER);
    if (count($header)) {
      await $handle->writeAsync(json_encode($header));
      if($handle is IO\_Private\PipeWriteHandle) {
        await $handle->closeAsync();
      }
      return new Response($handle, StatusCode::OK);
    }
    await $handle->writeAsync(json_encode([]));
    if($handle is IO\_Private\PipeWriteHandle) {
      await $handle->closeAsync();
    }
    return new Response($handle, StatusCode::OK);
  }
}