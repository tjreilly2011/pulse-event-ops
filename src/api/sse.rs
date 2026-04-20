use crate::domain::sse_event::SseEvent;
use axum::{
    extract::State,
    response::sse::{Event, KeepAlive, Sse},
};
use std::convert::Infallible;
use tokio::sync::broadcast;
use tokio_stream::Stream;

pub async fn stream_events(
    State(_tx): State<broadcast::Sender<SseEvent>>,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    // stub — real implementation in BE-06
    Sse::new(tokio_stream::empty()).keep_alive(KeepAlive::default())
}
