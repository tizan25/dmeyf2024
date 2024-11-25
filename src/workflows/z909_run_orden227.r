require("rlang")

# workflow que voy a correr
<<<<<<< HEAD
PARAM <- "src/workflows/991_workflow_orden228_SEMI.r"
=======
PARAM <- "src/workflows/991_workflow_orden227_SEMI_3RA.r"
>>>>>>> fbd745814ea3e715fa16b00c8c3417e9cd25f791

envg <- env()

envg$EXPENV <- list()
envg$EXPENV$repo_dir <- "~/dmeyf2024/"

#------------------------------------------------------------------------------

correr_workflow <- function( wf_scriptname )
{
  dir.create( "~/tmp", showWarnings = FALSE)
  setwd("~/tmp" )

  # creo el script que corre el experimento
  comando <- paste0( 
      "#!/bin/bash\n", 
      "source /home/$USER/.venv/bin/activate\n",
      "nice -n 15 Rscript --vanilla ",
      envg$EXPENV$repo_dir,
      wf_scriptname,
      "   ",
      wf_scriptname,
     "\n",
     "deactivate\n"
    )
  cat( comando, file="run.sh" )

  Sys.chmod( "run.sh", mode = "744", use_umask = TRUE)

  system( "./run.sh" )
}
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

# aqui efectivamente llamo al workflow
correr_workflow( PARAM )
