GMU_NAMESPACES_INIT();
// Create zoom actions
InputManager.CreateAction("zoom_in");
InputManager.CreateAction("zoom_out");

// Bind mouse wheel to actions
zoom_in_binding = InputManager.InputBindingFromMouseWheel(MOUSE_WHEEL.UP, 1);
zoom_out_binding = InputManager.InputBindingFromMouseWheel(MOUSE_WHEEL.DOWN, 1);

// Add bindings to actions
InputManager.GetAction("zoom_in").AddBinding(zoom_in_binding);
InputManager.GetAction("zoom_out").AddBinding(zoom_out_binding);
