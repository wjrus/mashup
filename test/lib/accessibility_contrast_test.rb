require "test_helper"

class AccessibilityContrastTest < ActiveSupport::TestCase
  STYLESHEET = Rails.root.join("app/assets/tailwind/application.css")
  THEME_SELECTORS = {
    light: ":root",
    dark: ':root[data-theme="dark"]',
    paper: ':root[data-theme="paper"]',
    terminal: ':root[data-theme="terminal"]',
    amber: ':root[data-theme="amber"]'
  }.freeze

  test "text and control colors meet WCAG AA contrast thresholds in every theme" do
    css = STYLESHEET.read

    THEME_SELECTORS.each do |theme, selector|
      tokens = theme_tokens(css, selector)

      assert_operator contrast(tokens.fetch("theme-text"), tokens.fetch("theme-panel")), :>=, 4.5,
        "#{theme} text contrast"
      assert_operator contrast(tokens.fetch("theme-muted"), tokens.fetch("theme-panel")), :>=, 4.5,
        "#{theme} muted text contrast"
      assert_operator contrast(tokens.fetch("theme-control-border"), tokens.fetch("theme-panel")), :>=, 3.0,
        "#{theme} control boundary contrast"
      assert_operator contrast(tokens.fetch("theme-focus"), tokens.fetch("theme-panel")), :>=, 3.0,
        "#{theme} focus indicator contrast"
    end
  end

  private

  def theme_tokens(css, selector)
    block = css.match(/#{Regexp.escape(selector)}\s*\{(?<body>.*?)\n\}/m)&.named_captures&.fetch("body")
    assert block, "Missing theme block for #{selector}"

    block.scan(/--([\w-]+):\s*(#[0-9a-fA-F]{6});/).to_h
  end

  def contrast(first, second)
    lighter, darker = [ luminance(first), luminance(second) ].sort.reverse
    (lighter + 0.05) / (darker + 0.05)
  end

  def luminance(color)
    channels = color.delete_prefix("#").scan(/../).map { |channel| channel.to_i(16) / 255.0 }
    linear = channels.map { |channel| channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4 }
    (0.2126 * linear[0]) + (0.7152 * linear[1]) + (0.0722 * linear[2])
  end
end
