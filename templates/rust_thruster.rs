use log::info;
use thruster::{
    context::typed_hyper_context::TypedHyperContext,
    hyper_server::HyperServer,
    m,
    middleware_fn, App, HyperRequest, MiddlewareNext, MiddlewareResult, ThrusterServer,
};


type Ctx = TypedHyperContext<RequestConfig>;

#[derive(Default)]
struct ServerConfig {}

#[derive(Default)]
struct RequestConfig {}

fn generate_context(request: HyperRequest, _state: &ServerConfig, _path: &str) -> Ctx {
    Ctx::new(
        request,
        RequestConfig {},
    )
}

#[middleware_fn]
async fn hello(mut context: Ctx, _next: MiddlewareNext<Ctx>) -> MiddlewareResult<Ctx> {
    context.body("Hello, world!");

    Ok(context)
}

#[tokio::main]
async fn main() {
    env_logger::init();
    info!("Starting server...");

    let app = App::<HyperRequest, Ctx, ServerConfig>::create(
        generate_context,
        ServerConfig {},
    )
    .get("/hello", m![hello]);

    let server = HyperServer::new(app);
    server.build("0.0.0.0", 4321).await;
}
