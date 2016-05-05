defmodule Omxplayer.Player do

  @executable "omxplayer"

  def get_executable do
    case System.find_executable( @executable ) do
      nil -> { :error, "Executable #{@executable} could not be found. Check your $PATH env var" }
      cmd -> { :ok, cmd }
    end
  end

  def get_pid do
    case System.cmd( "ps", ~w(-o pid= -C #{@executable}) ) do
      { resp, 0 }   -> { :ok, resp |> String.strip |> String.to_integer }
      { msg, _code } -> { :error, msg }
    end
  end

  def is_running? do
    case get_pid do
      { :ok, _pid } -> true
      _ -> false
    end
  end

  def installed? do
    case get_executable do
      { :error, _ } -> false
      { :ok, _ } -> true
      _ -> false
    end
  end

  def dbus_addr do
    case get_dbus_files do
      files when is_list( files ) ->
        dbus_file = Enum.find( files, fn file ->
          ! Regex.match?( ~r/\.pid$/, file )
        end )
        case dbus_file do
          nil  ->
            { :error, "Dbus file could not be found or is not readable by the current user." }
          file ->
            case File.read( "/tmp/#{dbus_file}" ) do
              { :ok, data } -> { :ok, String.strip( data ) }
              error -> error
            end
        end
    end
  end

  defp get_dbus_files do
    ls_mask "/tmp/", ~r/omxplayerdbus.*/
  end

  def ls_mask( path, mask ) do
    case File.ls path do
      { :ok, files } ->
        Enum.filter( files, fn file ->
          Regex.match?( mask, file )
        end )
      err -> err
    end
  end

  def play( url, args ) do
    if is_running? do
      stop
    end
    System.cmd( @executable, args )
  end

  def stop do
    #TODO
  end

  def pause do
    #TODO
  end

end