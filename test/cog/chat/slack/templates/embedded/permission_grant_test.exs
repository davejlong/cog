defmodule Cog.Chat.Slack.Templates.Embedded.PermissionGrantTest do
  use Cog.TemplateCase

  test "permission-grant template" do
    data = %{"results" => [%{"permission" => %{"bundle" => "site",
                                               "name" => "foo"},
                             "role" => %{"name" => "ops"}}]}

    expected = "Granted permission 'site:foo' to role 'ops'"
    assert_rendered_template(:slack, :embedded, "permission-grant", data, expected)
  end

  test "permission-grant template with multiple inputs" do
    data = %{"results" => [%{"permission" => %{"bundle" => "site", "name" => "foo"},
                             "role" => %{"name" => "ops"}},
                           %{"permission" => %{"bundle" => "site", "name" => "bar"},
                             "role" => %{"name" => "dev"}},
                           %{"permission" => %{"bundle" => "site", "name" => "baz"},
                             "role" => %{"name" => "sec"}}]}

    expected = """
    Granted permission 'site:foo' to role 'ops'
    Granted permission 'site:bar' to role 'dev'
    Granted permission 'site:baz' to role 'sec'
    """ |> String.strip

    assert_rendered_template(:slack, :embedded, "permission-grant", data, expected)
  end



end
