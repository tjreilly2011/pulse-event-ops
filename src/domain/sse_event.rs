use crate::domain::event::Event;
use crate::domain::event_update::EventUpdate;
use serde::Serialize;

#[derive(Debug, Clone, Serialize)]
#[serde(tag = "type", rename_all = "SCREAMING_SNAKE_CASE")]
pub enum SseEvent {
    EventCreated { event: Event },
    EventAcknowledged { event: Event },
    EventUpdateAdded { update: EventUpdate },
}
