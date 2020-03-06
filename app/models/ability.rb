class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
      user ||= User.new # guest user (not logged in)
      if user.admin?
        can :access, :curate
        can :access, :create_user

        can :request_feedback, Record
        can :request_opinions, Record
        can :recommend_changes, Record
        can :copy_recommendations, Record

        can :discuss_justification, Record

        can :provide_feedback, Record

        can :review_state, Record.aasm.states.map(&:name)

        can :force_close, Record
        can :close, Record

        can :replace_granule, Granule
        can :delete_granule, Granule
        can :create_granule, Collection
        can :associate_granule_to_collection, Collection

        can :access, :filter_daac

        can :search, :cmr

        can :release_to_daac, Record

        can :create_review_comments, Review
        can :view_review_comments, Review
        can :create_report_comments, Review
        can :view_report_comments, Review
      end

      if user.arc_curator?
        can :access, :curate

        can :request_opinions, Record
        can :recommend_changes, Record
        can :discuss_justification, Record
        can :provide_feedback, Record
        can :copy_recommendations, Record

        can :review_state, [Record::STATE_OPEN, Record::STATE_READY_FOR_DAAC_REVIEW, Record::STATE_IN_ARC_REVIEW, Record::STATE_CLOSED, Record::STATE_FINISHED]

        can :replace_granule, Granule
        can :delete_granule, Granule
        can :create_granule, Collection
        can :associate_granule_to_collection, Collection

        can :access, :filter_daac

        can :search, :cmr

        can :create_review_comments, Review
        can :view_review_comments, Review
        can :create_report_comments, Review
        can :view_report_comments, Review
      end

      if user.mdq_curator?
        can :access, :curate

        can :request_opinions, Record
        can :recommend_changes, Record
        can :discuss_justification, Record
        can :provide_feedback, Record
        can :copy_recommendations, Record

        can :review_state, [Record::STATE_OPEN, Record::STATE_READY_FOR_DAAC_REVIEW, Record::STATE_IN_ARC_REVIEW, Record::STATE_CLOSED, Record::STATE_FINISHED]

        can :replace_granule, Granule
        can :delete_granule, Granule
        can :create_granule, Collection
        can :associate_granule_to_collection, Collection

        can :access, :filter_daac

        can :search, :cmr

        can :create_review_comments, Review
        can :view_review_comments, Review
        can :create_report_comments, Review
        can :view_report_comments, Review
      end

      if user.daac_curator?
        can :access, :curate

        can :provide_feedback, Record

        can :close, Record

        can :review_state, Record::STATE_IN_DAAC_REVIEW

        can :create_report_comments, Review
        can :view_report_comments, Review

        can :view_edit_in_mmt_link, Collection

        can :update_email_preferences, user
      end

    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
