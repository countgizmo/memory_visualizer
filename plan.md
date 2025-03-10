# Day 1: Basic Window Setup

- [X] Set up Odin project with Raylib bindings
- [X] Create a window that clears to a background color
- [X] Draw a single static rectangle (placeholder for memory region)

Success = seeing a window with a colored rectangle

# Day 2: Mach Interface Setup

- [X] Add Mach system bindings to your project
- [X] Get task port for your own process
- [X] Print basic process info to console

Success = seeing your process ID and task port printed

# Day 3: Single Region Query

- [X] Query one memory region using vm_region_recurse
- [X] Print region info (address, size, protection)
- [X] Convert this info into a rectangle position/size
- [X] Draw the actual region instead of placeholder

Success = seeing one real memory region visualized

# Day 4: Region Iterator

- [X] Create iterator for memory regions
- [X] Store regions in a simple array/slice
- [X] Print all regions to console first

Success = seeing list of all memory regions

# Day 5: Full Visualization

- [x] Draw all memory regions as rectangles
- [X] Color code based on protection flags (read/write/execute)
- [X] Add basic text labels showing addresses

Success = seeing complete memory map

# Bonus features once basic visualization works:

Mouse hover to show region details
Zoom controls (Raylib makes this easy with mouse wheel)
Pan view for large memory maps
Different color schemes for different memory types
