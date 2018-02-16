defmodule Molabhbot.Accounts.Encryption do
  alias Comeonin.Bcrypt

  def hash_password(password) do
    Bcrypt.hashpwsalt(password)
  end

  def validate_password(password, hash) do
    Bcrypt.checkpw(password, hash)
  end

  def dummy_checkpw() do
    Bcrypt.dummy_checkpw()
  end

end
