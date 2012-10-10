function h = perler_gui()
% gui for mapping out perler designs
%

h = [];

fwidth = 800;
fheight = 500;

% initialize figure
h.fig = init_figure('Perler Design', false, false, 'w');
opos = get(h.fig, 'OuterPosition');
set(h.fig, 'OuterPosition', [opos(1) opos(2) fwidth fheight]);

% initialize board axis
h.board_ax = axes();
hold on; 
set(h.board_ax, 'Position', [0.05, 0.05, (fheight*0.9)/fwidth, 0.9]);
axis(h.board_ax, 'equal');
axis(h.board_ax, 'off');

% initialize palette axis
h.palette_ax = axes();
hold on; 
set(h.palette_ax, 'Position', [(fwidth - fheight*0.5)/fwidth, 0.05, (fheight*0.5)/fwidth, 0.5]);
axis(h.palette_ax, 'equal');
axis(h.palette_ax, 'off');

% perler bead data
h.beads = [];
h.beads.pos = [];
h.beads.h = [];
h.beads.r = 0.5;

% bead colors
h.icurrColor = 4;
h.colors = [   25   25   25; ... black
               96   96   96; ... dark grey
              164  164  164; ... grey
              255  255  255; ... white
               96   57   18; ... brown
              153  101   51; ... light brown
              211  173  108; ... tan
              228  190  145; ... sand
              240  233  189; ... cream
              239  191  191; ... peach
              138   33   37; ... cran
              234    0    1; ... red
              252   74   44; ... hot coral
              254   94   94; ... bubblegum
              254  128  129; ... pink
              255  169  168; ... light pink
              169   54   23; ... rust
              255   97    0; ... orange
              254  133   16; ... butterscotch
              255  168   16; ... cheddar
              255  228    0; ... yellow
              254  240  107; ... pastel yellow
               82    0  126; ... purple
              163   52  173; ... plum
              195  140  207; ... lavender
               14    0  123; ... dark blue
               41   24  180; ... neon blue
              100   92  152; ... periwinkle
               55  119  183; ... light blue
              101  160  218; ... pastel blue 
              138  198  226; ... toothpaste
               21  122    0; ... green
               48  137   79; ... parrot green
               76  182   90; ... light green
              101  205  116; ... pastel green
               80  244   36; ... lime green
                            ]'./255;
h.paletteLayout = {[1:4], [5:10], [11:16], [17:22], [23:25], [26:31], [32:36]};
h.selectedColorDisp = [];

% set function handle pointers
h.init_color_palette = @init_color_palette;
h.draw_circ = @draw_circ;
h.draw_hex_board = @draw_hex_board;
h.set_bead_ButtonDownFcn = @set_bead_ButtonDownFcn;
h.set_palette_ButtonDownFcn = @set_palette_ButtonDownFcn;
h.bead_click_callback = @bead_click_callback; 
h.palette_click_callback = @palette_click_callback; 
h.clear_current_board = @clear_current_board;
h.set_selected_color = @set_selected_color;

% initialize the board
h.init_color_palette();
h.draw_hex_board();


  function init_color_palette() 
    ogca = gca;
    axes(h.palette_ax);

    h.colorPalette = zeros(1,size(h.colors,2));

    % determine square size
    nrow = numel(h.paletteLayout);
    for r = 1:nrow
      icolors = h.paletteLayout{r};
      ncol = numel(icolors);
      for c = 1:ncol
        p = [(c-1) + 0.5 + 0.1*(c-1), nrow-r+1 - 0.1*(r-1)];
        h.colorPalette(icolors(c)) = h.draw_circ(p, 0.5, h.colors(:,icolors(c)), pi/50, true);
      end
    end

    % create selected color display
    h.selectedColorDisp = h.draw_circ([0.5, r + 0.6 + (r-1)*0.1], 0.5, h.colors(:,h.icurrColor), pi/50, true);

    axis(h.palette_ax, 'tight');
    axis(h.palette_ax, 'equal');

    axes(ogca);

    % set the button click callback function
    h.set_palette_ButtonDownFcn()
  end

  function draw_hex_board(r, rot90)
  % draws a hexagonal perler board
    if (clear_current_board() == false)
      return
    end

    if (nargin < 1)
      r = 9;
    end
    if (nargin < 2)
      rot90 = false;
    end

    R = eye(2);
    if (rot90);
      R = [0 -1; 1 0];
    end

    % handles for bead patches
    h.beads.h = zeros(1, 2*r+1 + 2*sum(2*r:-1:r+1));
    % bead positions
    h.beads.pos  = zeros(2, 2*r+1 + 2*sum(2*r:-1:r+1));

    ogca = gca;
    axes(h.board_ax);

    count = 1;
    for l = 0:r
      nc = 0;
      for x = -r+l*0.5:r-l*0.5
        p = R * [x+nc*0.1 l]';

        h.beads.h(count) = h.draw_circ(p, 0.5, 'w', pi/20, true);
        h.beads.pos(:,count) = p;
        count = count + 1;

        if (l > 0)
          p = R * [x+nc*0.1 -l]';
          h.beads.h(count) = h.draw_circ(p, 0.5, 'w', pi/20, true);
          h.beads.pos(:,count) = p;
          count = count + 1;
        end

        nc = nc + 1;
      end
    end

    axes(ogca);

    % set callback functions
    h.set_bead_ButtonDownFcn();

    axis(h.board_ax, 'tight');
    axis(h.board_ax, 'equal');
  end

  function set_bead_ButtonDownFcn()
    for i = 1:numel(h.beads.h)
      set(h.beads.h(i), 'ButtonDownFcn', h.bead_click_callback);
    end
  end
  
  function set_palette_ButtonDownFcn()
    for i = 1:numel(h.colorPalette)
      set(h.colorPalette(i), 'ButtonDownFcn', h.palette_click_callback);
    end
  end

  function bead_click_callback(obj_hdl, evt)
    set(obj_hdl, 'FaceColor', h.colors(:,h.icurrColor));
  end

  function palette_click_callback(obj_hdl, evt)
    h.set_selected_color(find(h.colorPalette == obj_hdl));
  end

  function set_selected_color(icolor)
    h.icurrColor = icolor;
    set(h.selectedColorDisp, 'FaceColor', h.colors(:,h.icurrColor));
  end

  function ret = clear_current_board()
    % TODO: prompt the user to make sure he wants to clear?
    h.beads.pos = [];
    for i = 1:numel(h.beads.h)
      delete(h.beads.h(i));
    end
    h.beads.h = [];
    ret = true;
  end
  

  function ph = draw_circ(t, scale, color, res, usePatch)
  % draw a circle
  % 
    if (nargin < 1 || isempty(t))
      t = [0 0]';
    end
    if (nargin < 2 || isempty(scale))
      scale = 1.0;
    end
    if (nargin < 3 || isempty(color))
      color = 'k';
    end
    if (nargin < 4 || isempty(res))
      res = pi/20;
    end
    if (nargin < 5 || isempty(usePatch))
      usePatch = false;
    end

    X = [cos(0:res:2*pi); sin(0:res:2*pi)];

    X = scale.*X + repmat(t(:), [1, size(X,2)]);

    if (usePatch)
      ph = patch(X(1,:), X(2,:), 'b');
      set(ph, 'FaceColor', color);
    else
      ph = plot(axHandle, X(1,:), X(2,:), 'Color', color);
    end
  end

end

