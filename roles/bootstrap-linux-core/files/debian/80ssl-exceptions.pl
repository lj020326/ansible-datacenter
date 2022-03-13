
// per: https://unix.stackexchange.com/questions/317695/is-it-possible-to-have-apt-accept-an-invalid-certificate
//Debug::Acquire::https "true";

// Except otherwise specified, use that list of anchors
//Acquire::https::CaInfo     "/etc/ssl/certs/ca-certificates.crt";

// docker
//Acquire::https::download.docker.com::Verify-Peer "false";
//Acquire::https::download.docker.com::Verify-Host "false";
