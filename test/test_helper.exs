ExUnit.start()
Mox.defmock(MiscMock, for: Behaviours.Misc)
Application.put_env(:genetic, :misc, MiscMock)
