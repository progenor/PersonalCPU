# 2026-05-24T23:50:21.519877900
import vitis

client = vitis.create_client()
client.set_workspace(path="PersonalCPU")

vitis.dispose()

