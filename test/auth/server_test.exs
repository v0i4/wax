defmodule Whatsapp.Auth.ServerTest do
  use ExUnit.Case
  doctest WhatsappApi

  import Mock
  alias Whatsapp.Auth.Server

  test "Should get auth header" do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          post!: fn _, _, _ ->
            %HTTPoison.Response{
              body: %{
                "users" => [
                  %{
                    "token" => "dXNlcm5hbWU6cGFzc3dvcmQ=",
                    "expires_after" => "2018-03-01 15:29:26+00:00"
                  }
                ]
              }
            }
          end
        ]
      }
    ]) do
      providers = [
        %{
          name: "My company",
          username: "username",
          password: "password",
          url: "https://wa.io:9090/v1"
        },
        %{
          name: "",
          username: "",
          password: "",
          url: ""
        }
      ]

      {:ok, _pid} = Server.start_link(providers)
      {url, auth_header} = Server.get_token_info("My company")

      assert url == "https://wa.io:9090/v1"
      assert auth_header == {"Authorization", "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="}
    end
  end

  test "Should be able to load provider configs after start" do
    with_mocks([
      {
        WhatsappApiRequest,
        [],
        [
          post!: fn _, _, _ ->
            %HTTPoison.Response{
              body: %{
                "users" => [
                  %{
                    "token" => "dXNlcm5hbWU6cGFzc3dvcmQ=",
                    "expires_after" => "2018-03-01 15:29:26+00:00"
                  }
                ]
              }
            }
          end
        ]
      }
    ]) do
      providers = [
        %{
          name: "My company",
          username: "username",
          password: "password",
          url: "https://wa.io:9090/v1"
        },
        %{
          name: "Whatsapp ES",
          username: "user_es",
          password: "pwd_ws",
          url: "https://wa.es.io:9090/v1"
        }
      ]

      {:ok, _pid} = Server.start_link()
      :ok = Server.load_config(providers)

      {url, auth_header} = Server.get_token_info("My company")

      assert url == "https://wa.io:9090/v1"
      assert auth_header == {"Authorization", "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="}

      {url, auth_header} = Server.get_token_info("Whatsapp ES")

      assert url == "https://wa.es.io:9090/v1"
      assert auth_header == {"Authorization", "Bearer dXNlcm5hbWU6cGFzc3dvcmQ="}
    end
  end
end
