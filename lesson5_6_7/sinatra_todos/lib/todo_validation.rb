module TodoValidation
  # Verifies if a list_name is valid. If not, it will render render_on_error,
  # otherwise it executes the block passed to it.
  def validate_list_name(render_on_error=:new_list)
    list_name = params[:list_name].strip

    if !(1..100).cover? list_name.size
      session[:error] = "List name must be between 1 and 100 characters"
    elsif session[:lists].any? { |list| list[:name] == list_name }
      session[:error] = "List name must be unique"
    end
    return erb render_on_error if session[:error]

    yield list_name
  end

  # Checks if a todo_name is valid for @list. Renders the :list view if not,
  # otherwise yields to the given block
  def validate_todo_name
    todo_name = params[:todo].strip

    if !(1..100).cover? todo_name.size
      session[:error] = "Todo name must be between 1 and 100 characters"
    elsif @list[:todos].any? { |todo| todo[:name] == todo_name }
      session[:error] = "Todo name must be unique"
    end
    return erb :list if session[:error]

    yield todo_name
  end

  def id_to_i(id)
    int_id = id.to_i
    return nil if int_id.to_s != id
    int_id
  end

  # Checks if list_id is valid. If its not, it redirects, otherwise it runs the
  # block passed to it.
  def validate_list
    list_id = id_to_i params[:list_id]

    unless (0...session[:lists].size).cover? list_id
      session[:error] = "The specified list does not exist."
      return redirect '/lists'
    end

    @list = session[:lists][list_id]
    yield list_id
  end

  # Checks if a todo_id is valid for @list. Renders the :list view if not,
  # otherwise yields to the given block
  def validate_todo
    todo_id = params[:todo_id].to_i

    unless (0...@list[:todos].size).cover? todo_id
      session[:error] = "The specified todo does not exist."
    end
    return erb :list if session[:error]

    yield todo_id
  end
end
