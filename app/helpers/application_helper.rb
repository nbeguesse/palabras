module ApplicationHelper

  def fill_class arr, int
    if arr.include?(int)
      "btn-primary"
    else
      "btn-outline-primary"
    end
  end

  def flash_class(level)
    case level
      when 'notice' then "alert alert-info"
      when 'success' then "alert alert-success"
      when 'error' then "alert alert-danger"
      when 'alert' then "alert alert-warning"
    end
  end

end
