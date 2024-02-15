defmodule ReceiptDecoder do
  @moduledoc """
  Decode iOS App receipt
  """

  alias ReceiptDecoder.Extractor
  alias ReceiptDecoder.Parser
  alias ReceiptDecoder.Verifier
  alias ReceiptDecoder.AppReceipt

  @type decode_option :: {:sandbox, boolean}

  @doc """
  Decode iOS App receipt.

  ## Example

  ```elixir
  iex> ReceiptDecoder.decode(BASE64_ENCODED_RECEIPT)
  {:ok,
   %ReceiptDecoder.AppReceipt{application_version: "1241",
    bundle_id: "com.sumiapp.GridDiary", creation_date: ~N[2014-09-02 03:29:06],
    environment: "ProductionSandbox", expiration_date: nil,
    in_apps: [%ReceiptDecoder.IAPReceipt{cancellation_date: nil,
      expires_date: nil, original_purchase_date: ~N[2014-08-04 06:24:51],
      original_transaction_id: "1000000118990828",
      product_id: "com.sumiapp.GridDiary.pro",
      purchase_date: ~N[2014-09-02 03:29:06], quantity: 1,
      transaction_id: "1000000118990828", web_order_line_item_id: 0},
     %ReceiptDecoder.IAPReceipt{cancellation_date: nil, expires_date: nil,
      original_purchase_date: ~N[2014-09-02 03:29:06],
      original_transaction_id: "1000000122102348",
      product_id: "com.sumiapp.griddiary.test",
      purchase_date: ~N[2014-09-02 03:29:06], quantity: 1,
      transaction_id: "1000000122102348", web_order_line_item_id: 0}],
    opaque_value: <<55, 223, 114, 56, 138, 79, 247, 183, 9, 37, 209, 28, 7, 147,
      201, 131>>, original_application_version: "1.0",
    sha1_hash: <<253, 23, 138, 194, 193, 253, 204, 39, 239, 220, 43, 200, 223,
      213, 74, 210, 39, 101, 79, 47>>}}
  ```

  ### Options

  * `:sandbox` - Use this value during development to skip the verification of the certifications

  """
  @spec decode(String.t(), [decode_option]) :: {:ok, AppReceipt.t()} | {:error, any}
  def decode(base64_receipt, opts \\ []) do
    with {:ok, receipt} <- Extractor.decode_receipt(base64_receipt),
         :ok <- verify(receipt, opts),
         {:ok, payload} <- Extractor.extract_payload(receipt),
         {:ok, app_receipt} <- Parser.parse_payload(payload) do
      {:ok, app_receipt}
    else
      err -> err
    end
  end

  defp verify(receipt, opts) do
    if Keyword.get(opts, :sandbox, false),
      do: :ok,
      else: Verifier.verify(receipt)
  end
end
