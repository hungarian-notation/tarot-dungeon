local cards = {}
local gfx = love.graphics

local CARD_ASPECT = 0.7 -- Width/Height
local TITLE_ASPECT = 4.0
local BORDER_RATIO = 0.02

local CARD_BORDER_COLOR = { 0xFF, 0xFF, 0xFF }
local CARD_BACKGROUND_COLOR = { 0x00, 0x00, 0x00 }
local CARD_TEXT_COLOR = { 0xFF, 0xFF, 0xFF }

function cards.get_metrics(args)
  local metrics = {}

  if type(args) == 'number' then
    args = { scale=args }
  end

  assert(args.scale)
  
  metrics.scale = args.scale
  metrics.width = args.scale
  metrics.height = metrics.width / CARD_ASPECT
  
  metrics.card_width = metrics.width
  metrics.card_height = metrics.height
  
  metrics.border_width = BORDER_RATIO * args.scale
  metrics.inner_width = metrics.width - (metrics.border_width * 2)
  
  metrics.title_width = metrics.inner_width
  metrics.title_height = metrics.title_width / TITLE_ASPECT
  metrics.title_offset = vector(metrics.border_width, metrics.height - metrics.border_width - metrics.title_height)
  
  metrics.portrait_width = metrics.inner_width
  metrics.portrait_height = metrics.height - 3 * metrics.border_width - metrics.title_height
  metrics.portrait_offset = vector(metrics.border_width, metrics.border_width)
  
  return metrics
end

function cards.draw_card_border(args, metrics)
  metrics = metrics or cards.get_metrics(args)
  
  gfx.setColor(CARD_BORDER_COLOR)
  gfx.rectangle("fill", args.position.x, args.position.y, metrics.width, metrics.height)
  gfx.setColor(CARD_BACKGROUND_COLOR)
  
  gfx.rectangle("fill", -- draw title placard
    args.position.x + metrics.border_width, 
    args.position.y + metrics.height - metrics.border_width - metrics.title_height,
    metrics.title_width,
    metrics.title_height
  )
  
  gfx.rectangle("fill", -- draw portrait background
    args.position.x + metrics.border_width,
    args.position.y + metrics.border_width,
    metrics.portrait_width,
    metrics.portrait_height
  )
  
end

function cards.draw_card(card, metrics)
  metrics = metrics or cards.get_metrics(card)
  
	assert(card.title, "missing card title")
  assert(card.position, "missing card position")
  
  cards.draw_card_border(card, metrics)
  
  gfx.setColor(CARD_TEXT_COLOR)
  gfx.print(card.title, 
    card.position.x + metrics.title_offset.x + metrics.border_width, 
    card.position.y + metrics.title_offset.y + metrics.border_width
  )
  
end

return cards