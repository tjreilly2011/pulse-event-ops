use std::convert::Infallible;

use axum::{
    extract::State,
    response::sse::{Event, KeepAlive, Sse},
};
use tokio::sync::broadcast;
use tokio_stream::{wrappers::BroadcastStream, StreamExt};

use crate::domain::sse_event::SseEvent;

pub async fn stream_events(
    State(tx): State<broadcast::Sender<SseEvent>>,
) -> Sse<impl tokio_stream::Stream<Item = Result<Event, Infallible>>> {
    let rx = tx.subscribe();
    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
        Ok(ev) => {
            let data = serde_json::to_string(&ev).ok()?;
            Some(Ok(Event::default().data(data)))
        }
        Err(_) => None, // lagged subscriber — skip, stay connected
    });
    Sse::new(stream).keep_alive(KeepAlive::default())
}
