class FilterModule(object):
    def filters(self):
        import base64
        return {
            'decap_pem': lambda src: ''.join(l for l in src.splitlines(False)[1:-1]),
            'rawb64decode': lambda src: base64.b64decode(src),
            'dump_byte_string': lambda src: ''.join(r'\x{:02x}'.format(i) for i in src)
        }
