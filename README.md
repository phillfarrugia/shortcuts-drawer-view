# shortcuts-drawer-view
An experimental re-creation of Siri Shortcut's Drawer View component, built [for this Medium Article](https://medium.com/@phillfarrugia/re-creating-the-siri-shortcuts-drawer-interaction-9b2bc94e0b05)

![Inspecting in Reveal](https://i.imgur.com/5rCGs4v.png)

## Description

As you begin creating using Siri Shortcuts one of the first thing’s you’ll notice is the ‘Drawer View’ component that sits at the bottom of the screen. It can be pulled out, tapped on, extended, scrolled and closed in many different ways. It presents a list of steps and integrations that can be added to a Shortcut. In true Apple fashion, the ‘Drawer View’ is a unique component in that it is there when you need it, but it can be pushed out of the way when it’s not needed, freeing up the screen space to do other things. It’s not a Modal, or a Push, so as a user you’re never taken too far away from the task at hand.

It looks like a simple enough component at first, but as you begin to look closer you’ll start to realize it’s actually doing a lot in order to create a seamless, unobtrusive editing experience.

I decided to spend some time trying to re-create the Siri Shortcuts Drawer View myself so that I could try to understand the complexity behind it, the interaction problems it solves and to learn more about UIKit.

# Features

### Size States 

#### Size States
What becomes most obvious when playing around with Shortcuts is that the drawer view has three core states that it is always switching between.

#### Compressed
It’s tucked down at the bottom of the screen, at its most compact size. It displays a Search Bar which is tappable and the view itself can be pulled up.

#### Expanded
It’s slightly taller, and displays a Search Bar, a title label and a small list of options or cells that can be tapped, and the view itself can be pulled up but the list cannot be scrolled.

#### Full Height
It’s at its largest size, almost the entire height of the containing view, although there’s still a slight gap above. It displays a Search Bar, title label and a long list of options or cells that can be tapped and the list (Scroll View) can be scrolled revealing more option cells. The view itself can be pulled down to return back to its previous smaller states.

### Functional Requirements
What are the functional requirements of the component that my recreation must achieve in order to satisfy the solution?

- Needs to display a view of content at the bottom of the screen
- Needs to present the view above another visible view of content
- Needs to enable interaction with both the view itself and it’s content view simultaneously
- Needs to enable pulling up and down on the view to expand and compress it
- Needs to snap between three distinct heights “compressed”, “expanded” and “full height”
- Needs to enable scrolling through the content view’s scroll view, as well as panning the view itself
- Needs to darken the background of the containing view when it is at its “full height”.

### Non-Functional Requirements
- Needs to have smooth, buttery spring animations as it switches between states
- Needs to transition between scrolling content and panning the view seamlessly, without lifting a finger
- Needs to be feel and scroll fast but not have a significant performance impact on the device
- Needs to look like a native iOS component and make use of only standard UIKit interface elements
- In a production environment it might also need to support Accessibility (Voice Over, Dynamic Text, Screen Readers etc), Localization, Re-Usability and different forms of internal content.

### UIPanGestureRecognizer vs UIScrollView

To handle pan gestures a UIPanGestureRecognizer is added to the child view controller’s view. Nested inside the child’s subviews is a UITableView displaying cells representing Shortcut options. Internally UITableView’s UIScrollView uses a UIPanGestureRecognizer to drive the scrolling interaction. Obviously these nested UIPanGestureRecognizers are a recipe for complexity.

A gesture recognizer’s delegate can control how the recognizer behaves when it is triggered alongside another UIGestureRecognizer. It can choose to override the other recognizer, or let the other recognizer take a given touch event by returning true or false accordingly.

In the case of the Drawer view providing a delegate to the child’s UIPanGestureRecognizer enables the child to determine if a touch event is handled by the drawer itself as a pan, or the UITableView as a content scroll. To determine that the Velocity, ExpansionState and y ContentOffset of the table view are used to determine the direction of the pan (Up or Down) and the y contentOffset to determine the position within the UIScrollView. If the Drawer is in its Compressed or Expanded states the user should not be able to scroll the UITableView’s content — so we return false. If the Drawer is in its Full Height position we want to —

- Allow the user to scroll down through the UITableView’s content.
- Allow the user to scroll up through the content until they reach the top.
- Stop the user from scrolling down while at the top of the UITableView’s content and rubber banding the UIScrollView. This gesture is used to pan the Drawer down into its Expanded or Compressed state.
- Using the Velocity, if the user is panning Down true is returned. If the user is panning Up, the y contentOffset is checked and true or false is returned as needed.



## Contributions

I have no immediate plans to actively work on this experiment any further. However this source code is licensed under the [MIT license](https://github.com/phillfarrugia/swipeable-view-stack/blob/master/LICENSE) which permits anyone to fork this repository and make modifications under the same license.
