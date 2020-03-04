import dxfeed as dx


def test_connection():
    con = dx.dxf_create_connection()
    exp_status = 'Connected'
    act_status = dx.dxf_get_current_connection_status(con)
    assert exp_status == act_status