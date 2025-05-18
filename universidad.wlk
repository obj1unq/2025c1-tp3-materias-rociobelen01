class Materia {
    var property nombre
    var property carrera  // carrera a la que pertenece
    var property requisitos = #{} 
    var property cupo
    var property inscriptos = #{} 
    var property listaDeEspera = []

// Punto 7
    method darDeBaja(estudiante){
        self.validarBaja(estudiante) // valido si el estudiante estaba inscripto
        inscriptos.remove(estudiante)
        estudiante.materiasInscriptas().remove(self)
        self.reasignarCupo()
    }

    method validarBaja(estudiante){
        if(not self.cumpleCondicionesDeBaja(estudiante)){
            self.error("El estudiante no esta inscripto en la materia")
        }
    }

    method reasignarCupo() {
        if (not listaDeEspera.isEmpty()){
            const estudianteN = listaDeEspera.first()
            listaDeEspera.remove(estudianteN)
            estudianteN.materiasEnEspera().remove(self)
            estudianteN.inscribirAMateria(self)
        }
    }

    method cumpleCondicionesDeBaja(estudiante){
        return inscriptos.contains(estudiante) && estudiante.estaInscripto(self)
    }

// Punto 8 
    method estudiantesInscriptos(){
        return inscriptos
    }

    method estudiantesEnListaDeEspera(){
        return listaDeEspera
    }
//
}

class Carrera {
    var property nombre
    var property materias = #{}

    method agregarMateria(materia){
        materias.add(materia)
    }

}

class Aprobar {
    var property nota
    var property materia

    method esValida(){
        return nota>= 4
    }
}

class Estudiante {
    var property nombre
    var property carreras = #{}
    var property materiasInscriptas = #{} // materias donde estoy inscripto 
    var property materiasEnEspera  =  #{} // materias donde estoy en lista de espera
    var property materiasAprobadas = #{}  // objetos Aprobacion

    method inscribirACarrera(carrera){
        carreras.add(carrera)
    }
    //1
    method aprobarMateria(materia, nota) {
    self.validarMateriaAprobada(materia, nota) //3
    const materiaNueva = new Aprobar(materia = materia, nota = nota) // Declaro la aprobacion de dicha materia con la nota
    materiasAprobadas.add(materiaNueva)                              // agrego la aprobacion
    }

    method validarMateriaAprobada(materia, nota) {
        if (nota < 4 || self.tieneAprobada(materia)) {
            self.error("No se puede aprobar la materia")
        }
    }
    //2
    method tieneAprobada(materia){
    return materiasAprobadas.any{ a => a.materia() == materia }
    }

    method cantidadMateriasAprobadas(){
        return materiasAprobadas.size()
    }

    method promedio(){
        return materiasAprobadas.average{materia => materia.nota()}
     }
    //4
    method colectionDeMaterias(){
        return carreras.map{ c => c.materias()}.flatten()
    }
    //6
    method inscribirAMateria(materia){
        self.validarIncripcion(materia) // 5 
        if(materia.cupo() > materia.inscriptos().size()){
            self.materiasInscriptas().add(materia)
            materia.inscriptos().add(self)
        } else {
            self.materiasEnEspera().add(materia)
            materia.listaDeEspera().add(self)
        }
    }

    method validarIncripcion(materia){
        if (not self.condicionesParaIncribirse(materia)){
            self.error("No cumples los requisitos para inscribirte a la materia")
        }
    }

    method condicionesParaIncribirse(materia){
        return self.perteneceAUnaCarreraCursada(materia)
            && not self.tieneAprobada(materia)
            && not self.estaInscripto(materia)
            && self.tieneAprobadosRequisitos(materia)
    }

    method perteneceAUnaCarreraCursada(materia){
        return self.carreras().any({c => c.materias().contains(materia)})
    }

    method estaInscripto(materia){
        return materiasInscriptas.contains(materia)
    }

    method tieneAprobadosRequisitos(materia){
        return materia.requisitos().all({requisito => self.tieneAprobada(requisito)})
    }

    //9
    method materiasEnLasQueEstoyIncripto(){
        return materiasInscriptas
    }
    
    method materiasEnListaDeEspera(){
        return materiasEnEspera
    }

    //10
    method materiasALasQueMePuedoInscribirEn(carrera){
        self.validarCarrera(carrera)
        return carrera.materias().filter({m => self.condicionesParaIncribirse(m)})
    }

    method validarCarrera(carrera){
        if (not carreras.contains(carrera)){
            self.error("El estudiante no cursa la carrera solicitada")
        }
    }
}
