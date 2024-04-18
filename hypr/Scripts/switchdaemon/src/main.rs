//use hyprland::data::{Client, Clients, Monitors, Workspace};
//use hyprland::dispatch::*;
use hyprland::event_listener::EventListenerMutable as EventListener;
//use hyprland::prelude::*;

fn main() -> hyprland::Result<()> {
    // We can call dispatchers with the dispatch macro, and struct!
    // You can decide what you want to use, below are some examples of their usage
    // and printing them all out!

    // Create a event listener
    let mut event_listener = EventListener::new();

    
    // add event, yes functions and closures both work!
    event_listener.add_workspace_change_handler(|id, _| println!("workspace changed to {id:#?}"));

    // and execute the function
    // here we are using the blocking variant
    // but there is a async version too
    event_listener.start_listener()
}
