local cell_lib = {}

function cell_lib.create(col_or_table, row)
  
  if type(col_or_table) == 'table' then
    return { col=col_or_table.col, row=col_or_table.row }
  elseif type(col_or_table) == 'number' and type(row) == 'number' then
    return { col=col_or_table, row=row }
  else 
    error("expected { col=[number], row=[number] } or ([number] col, [number] row)")
  end
  
end

return cell_lib