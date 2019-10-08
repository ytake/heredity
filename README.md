# heredity

Middleware Dispatcher For Hack.  

[![Build Status](https://travis-ci.org/nazg-hack/heredity.svg?branch=master)](https://travis-ci.org/nazg-hack/heredity)

PSR-7 HTTP message library Not Supported.  
Supported Only Hack library.  
*Required HHVM >= 4.20.0*

- [ytake/hungrr](https://github.com/ytake/hungrr)
- [usox/hackttp](https://github.com/usox/hackttp)

## install

```bash
$ composer require nazg/heredity
```

## Usage

### Basic

#### 1. Example Simple Request Handler

```hack
use type Nazg\Http\Server\RequestHandlerInterface;
use type Facebook\Experimental\Http\Message\ServerRequestInterface;
use type Facebook\Experimental\Http\Message\ResponseInterface;
use type Ytake\Hungrr\Response;
use type Ytake\Hungrr\StatusCode;
use type NazgHeredityTest\Middleware\MockMiddleware;
use namespace HH\Lib\Experimental\IO;
use function json_encode;

final class SimpleRequestHandler implements RequestHandlerInterface {

  public function handle(
    IO\WriteHandle $handle,
    ServerRequestInterface $request
  ): ResponseInterface {
    $header = $request->getHeader(MockMiddleware::MOCK_HEADER);
    if (count($header)) {
      $handle->rawWriteBlocking(json_encode($header));
      return new Response($handle, StatusCode::OK);
    }
    $handle->rawWriteBlocking(json_encode([]));
    return new Response($handle, StatusCode::OK);
  }
}
```

#### 2. Creating Middleware

```hack
use type Facebook\Experimental\Http\Message\ResponseInterface;
use type Facebook\Experimental\Http\Message\ServerRequestInterface;
use type Nazg\Http\Server\MiddlewareInterface;
use type Nazg\Http\Server\RequestHandlerInterface;
use type HH\Lib\Experimental\IO\WriteHandle;

class SimpleMiddleware implements MiddlewareInterface {

  public function process(
    WriteHandle $writeHandle,
    ServerRequestInterface $request,
    RequestHandlerInterface $handler,
  ): ResponseInterface {
    // ... do something and return response
    return $handler->handle($writeHandle, $request);
  }
}

```

#### 3. Middleware

```hack
use type Nazg\Heredity\Heredity;
use type Nazg\Heredity\MiddlewareStack;
use type Ytake\Hungrr\ServerRequestFactory;
use namespace HH\Lib\Experimental\IO;

list($read, $write) = IO\pipe_non_disposable();
$heredity = new Heredity(
    new MiddlewareStack([
      SimpleMiddleware::class
    ]),
    new SimpleRequestHandler()
  );
$response = $heredity->handle($write, ServerRequestFactory::fromGlobals());

```

### With Dependency Injection Container

example. [nazg-hack/glue](https://github.com/nazg-hack/glue)

```hack
use type Psr\Container\ContainerInterface;
use type Nazg\Http\Server\MiddlewareInterface;
use type Nazg\Heredity\Exception\MiddlewareResolvingException;
use type Nazg\Heredity\Resolvable;

use function sprintf;

class PsrContainerResolver implements Resolvable {

  public function __construct(
    protected ContainerInterface $container
  ) {}

  public function resolve(
    classname<MiddlewareInterface> $middleware
  ): MiddlewareInterface {
    if ($this->container->has($middleware)) {
      $instance = $this->container->get($middleware);
      if ($instance is MiddlewareInterface) {
        return $instance;
      }
    }
    throw new MiddlewareResolvingException(
      sprintf('Identifier "%s" is not binding.', $middleware),
    );
  }
}
```
