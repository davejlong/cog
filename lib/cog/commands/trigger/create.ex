defmodule Cog.Commands.Trigger.Create do
  use Cog.Command.GenCommand.Base,
    bundle: Cog.Util.Misc.embedded_bundle,
    name: "trigger-create"

  alias Cog.Repository.Triggers
  require Cog.Commands.Helpers, as: Helpers

  @description "Create a pipeline trigger."

  @arguments "<name> <pipeline>"

  @examples """
  trigger create my-trigger "echo 'Hello World'" -d "A friendly greeting"
  """

  @output_description "Returns the json for the newly created trigger."

  @output_example """
  [
    {
      "timeout_sec": 30,
      "pipeline": "echo fizbaz",
      "name": "foobar",
      "invocation_url": "http://localhost:4001/v1/triggers/00000000-0000-0000-0000-000000000000",
      "id": "00000000-0000-0000-0000-000000000000",
      "enabled": true,
      "description": null,
      "as_user": null
    }
  ]
  """

  option "enabled", type: "bool", short: "e", description: "Should the trigger be created in an enabled state, or not? Defaults to true."
  option "description", type: "string", short: "d", description: "Free text description of the trigger. Defaults to nil."
  option "timeout-sec", type: "int", short: "t", description: "Amount of time Cog will wait for execution to finish. Defaults to 30. Must be greater than 0"
  option "as-user", type: "string", short: "u", description: "The Cog username the trigger will execute as. Defaults to nil."

  permission "manage_triggers"

  rule "when command is #{Cog.Util.Misc.embedded_bundle}:trigger-create must have #{Cog.Util.Misc.embedded_bundle}:manage_triggers"

  def handle_message(req, state) do
    results = with {:ok, [name, pipeline]} <- Helpers.get_args(req.args, 2) do
      params = Cog.Command.Trigger.Helpers.normalize_params(req.options)
      |> Map.put("pipeline", pipeline)
      |> Map.put("name", name)

      case Triggers.new(params) do
        {:ok, trigger} ->
          {:ok, trigger}
        {:error, error} ->
          {:error, {:trigger_invalid, error}}
      end
    end

    case results do
      {:ok, data} ->
        {:reply, req.reply_to, "trigger-create", Cog.Command.Trigger.Helpers.convert(data), state}
      {:error, error} ->
        {:error, req.reply_to, Helpers.error(error), state}
    end
  end
end
