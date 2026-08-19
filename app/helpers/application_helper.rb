module ApplicationHelper
  def accessible_field_options(form, attribute, options = {})
    return options unless form.object.errors[attribute].any?

    aria = options.fetch(:aria, {}).merge(
      invalid: true,
      describedby: field_error_id(form, attribute)
    )
    options.merge(aria: aria)
  end

  def field_error(form, attribute)
    messages = form.object.errors[attribute]
    return if messages.empty?

    content_tag :p, messages.to_sentence,
      id: field_error_id(form, attribute),
      class: "field-error"
  end

  private

  def field_error_id(form, attribute)
    "#{form.field_id(attribute)}_error"
  end
end
