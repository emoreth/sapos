# Copyright (c) 2013 Universidade Federal Fluminense (UFF).
# This file is part of SAPOS. Please, consult the license terms in the LICENSE file.

module ApplicationHelper
  include NumbersHelper
  include PdfHelper

  def display_none_if_logged_out
    'style="display:none;"'.html_safe unless user_signed_in?
  end

  def transparent_if_logged_out
    'style="background: transparent;border: 0;"'.html_safe unless user_signed_in?
  end

  def rescue_blank_text(text = nil, options = {})
    options[:blank_text] ||= I18n.t('rescue_blank_text')
    if options[:method_call]
      text.blank? ? options[:blank_text] : text.send(options[:method_call])
    else
      text.blank? ? options[:blank_text] : text
    end
  end
end
